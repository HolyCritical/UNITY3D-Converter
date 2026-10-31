# .UNITY3D Android 2 iOS

Converts Unity3D asset bundles from Android to iOS. Retargets the platform flag
and re-encodes Android GPU textures to ASTC.

## Download it

Grab the portable build from [Releases](../../releases/latest). No Python, no
installer, no setup.

1. Download `UNITY3D-Converter-Portable.zip`
2. Extract anywhere, e.g. `C:\Tools\UNITY3D-Converter`
3. Double-click `start-webclient.bat`

Your browser opens `http://127.0.0.1:8765/`. Drop a `.zip` of a bundle pack,
pick a quality, download the iOS pack. Everything runs on your machine, nothing
is uploaded.

Command line, from inside the extracted folder:

```
run-cli.bat convert "D:\pack" -o out --rename-platform-dirs
run-cli.bat inspect "D:\pack"
run-cli.bat --help
```

Windows only. The bundle carries its own Python 3.13 runtime, so do not delete
or move the `python\` folder.

## Run from source

If you would rather use the repository instead of the portable build, you need
**Python 3.13 exactly** installed — newer versions cannot load the compiled
runtime and have no prebuilt wheels for the dependencies.

```
install-dependencies.bat
```

Creates `.venv`, installs dependencies, and verifies the tool loads. Then:

```
start-webclient.bat
```

or on the command line:

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
| `--report` | none | write a JSON report |

Full list: `run-cli.bat --help`

## Notes

- Textures already ASTC or PVRTC are left untouched.
- Sound banks are verified and copied byte-for-byte; they need no re-encoding.
- Folder structure is mirrored exactly and checked after every run.
- iOS side needs A8 (iPhone 6) or newer for ASTC.

Assets convert; native code does not. Operates on extracted bundle trees, not
APK/IPA containers.

## License

MIT, see [LICENSE](LICENSE).
