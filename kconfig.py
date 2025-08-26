import json
import os
import re


def test_val_to_kconfig():
    assert val_to_kconfig({"freeform": "0x123"}) == "0x123"
    assert val_to_kconfig({"freeform": 123}) == "123"
    assert val_to_kconfig({"freeform": "/nix/store/foobar"}) == '"/nix/store/foobar"'
    assert val_to_kconfig({"freeform": "asdf"}) == '"asdf"'
    assert val_to_kconfig({"freeform": "asdf"}) == '"asdf"'
    assert val_to_kconfig({"tristate": "y"}) == "y"
    assert val_to_kconfig({"tristate": "n"}) == None
    assert val_to_kconfig({"tristate": None}) == None
    try:
        val_to_kconfig({"tristate": "m"})
        raise AssertionError("unreachable")
    except ValueError:
        ...
    except:
        raise AssertionError("unreachable")


def val_to_kconfig(val) -> str | None:
    freeform = val.get("freeform")
    if freeform is not None:
        if isinstance(freeform, str) and (
            (os.path.isfile(freeform) or os.path.isdir(freeform))
            or (re.match("[0-9]+", freeform) is None)
        ):
            return f'"{freeform}"'

        return str(freeform)

    tristate = val.get("tristate")
    if tristate == "m":
        raise ValueError(f"invalid kconfig value {val}")

    match tristate:
        case "y":
            return "y"
        case "n" | None:
            return None


def main():
    nix_attrs_json_file = os.environ.get("NIX_ATTRS_JSON_FILE")

    if nix_attrs_json_file is None:
        raise ValueError("NIX_ATTRS_JSON_FILE is not set")

    with open(nix_attrs_json_file) as f:
        nix_attrs = json.load(f)

        kconfig = nix_attrs.get("kconfig")
        if kconfig is None:
            exit(0)

        for key, val in kconfig.items():
            val = val_to_kconfig(val)
            if val is None:
                print(f"# CONFIG_{key} is not set")
            else:
                print(f"CONFIG_{key}={val}")


if __name__ == "__main__":
    main()
