{ lib }:
let
  yes = { ubootType = "bool"; value = true; };
  no = { ubootType = "bool"; value = false; };
  unset = { ubootType = "bool"; value = null; };
  freeform = value: { ubootType = "freeform"; inherit value; };

  deserializeRawValue = value:
    if lib.hasPrefix "\"" value && lib.hasSuffix "\"" value then # string
      builtins.substring (1) (lib.stringLength value - 2) value
    else if lib.hasPrefix "0x" value then # hex string
      value
    else
      lib.toIntBase10 value;
in
{
  _internal = rec {
    deserialize = defconfig: builtins.listToAttrs
      (map
        (line:
          let
            name = builtins.elemAt line 1;
            rawValue = builtins.elemAt line 2;
            value = {
              "y" = yes;
              "n" = no;
              "is not set" = unset;
            }.${rawValue} or (freeform (deserializeRawValue rawValue));
          in
          lib.nameValuePair name value)
        (lib.filter
          (line: line != null && (
            # ensure that we only include valid "is not set" lines
            (builtins.elemAt line 0 == "# ") -> (builtins.elemAt line 2 == "is not set")
          ))
          (map
            (builtins.match "^(# )?CONFIG_([A-Z0-9_]+)[=| is not set](.*)$")
            (lib.splitString "\n" defconfig))));

    serialize = configAttrs: _serialize { inherit configAttrs; debug = false; };
    debugSerialize = configAttrs: _serialize { inherit configAttrs; debug = true; };

    _serialize = { configAttrs ? { }, debug ? false }:
      lib.concatStringsSep "\n" (lib.mapAttrsToList
        (kconfOption: answer:
          let
            optionName = "CONFIG_${kconfOption}";
            kconfLine = {
              "bool" =
                if answer.value == null then
                  "# ${optionName} is not set"
                else
                  "${optionName}=${if answer.value then "y" else "n"}";
              "freeform" =
                if (lib.isString answer.value
                  || lib.isPath answer.value
                  || lib.isDerivation answer.value
                ) &&
                !(lib.hasPrefix "0x" answer.value) then
                  "${optionName}=\"${answer.value}\""
                else
                  "${optionName}=${toString answer.value}";
            }.${answer.ubootType};
          in
          if debug then
            lib.trace "GENERATED: ${kconfLine}" kconfLine
          else
            kconfLine
        )
        configAttrs);
  };

  _external = { inherit yes no unset freeform; };
}

