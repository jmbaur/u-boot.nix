{ lib }: {
  _internal = {
    serialize = configAttrs: lib.concatLines
      (lib.mapAttrsToList
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
          kconfLine
        )
        configAttrs);
  };

  _external = {
    yes = { ubootType = "bool"; value = true; };
    no = { ubootType = "bool"; value = false; };
    unset = { ubootType = "bool"; value = null; };
    freeform = value: { ubootType = "freeform"; inherit value; };
  };
}
