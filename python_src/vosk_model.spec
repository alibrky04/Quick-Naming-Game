# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['vosk_model.py'],
    pathex=[],
    binaries=[],
    datas=[('vosk_model', 'vosk_model'), ('.venv/Lib/site-packages/vosk', 'vosk')],
    hiddenimports=['pyaudio', 'vosk'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='vosk_model',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
