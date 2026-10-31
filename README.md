# .UNITY3D Android 2 iOS

Converts Unity3D asset bundles from Android to iOS. Retargets the platform flag
and re-encodes Android GPU textures to ASTC.

## Download it

Download as ZIP (From the Green Code Button Dropdown, Extract.)

## Run it

**Windows, first time:**

```
install-dependencies.bat
```

Checks for Python 3.13, creates `.venv`, installs dependencies, and verifies the
tool loads.

**Then, for the drag-and-drop UI:**

```
start-webclient.bat
```

Opens `http://127.0.0.1:8765/`. Drop a `.zip` of a bundle pack, pick a quality,
download the iOS pack. Runs entirely on your machine.

**Command line:**

```
.venv\Scripts\python.exe -m u3dconv convert "D:\pack" -o out --rename-platform-dirs
.venv\Scripts\python.exe -m u3dconv inspect "D:\pack"
```

## Options

| flag | default | meaning |
|---|---|---|
| `--to` | `ios` | target platform |
| `--astc-block` | `6` | `4` best quality, `6` balanced, `8` smaller, `12` smallest |
| `--rename-platform-dirs` | off | rename `android` folders to `ios` |
| `--flatten` | off | drop wrapper folders from the output |
| `--aggressive` | off | also re-encode uncompressed textures |
| `--no-mips` | off | drop mipmaps instead of preserving |
| `--packer` | `original` | `original`, `none`, `lz4`, `lz4hc`, `lzma` |
| `--jobs` | CPU count | worker processes |
| `--dry-run` | off | analyze without writing |
| `--report` | — | write a JSON report |

Full list: `python -m u3dconv convert --help`

## Notes

- Textures already ASTC or PVRTC are left untouched.
- Sound banks are verified and copied byte-for-byte; they need no re-encoding.
- Folder structure is mirrored exactly and checked after every run.
- Requires Python 3.13 exactly. Newer versions (3.14, 3.15) cannot load the
  compiled runtime and have no prebuilt wheels for the dependencies. iOS side
  needs A8 (iPhone 6) or newer for ASTC.

Assets convert; native code does not. Operates on extracted bundle trees, not
APK/IPA containers.

## License

MIT — see [LICENSE](LICENSE).
