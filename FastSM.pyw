import time
import threading
_start = time.time()
def _log(msg):
	print(f"[{time.time() - _start:.2f}s] {msg}")

# Start importing atproto immediately in background (takes ~35s)
# This gives it a head start while we do other imports
def _preimport_atproto():
	try:
		import atproto
	except:
		pass
threading.Thread(target=_preimport_atproto, daemon=True).start()

_log("Starting imports...")
import application
from application import get_app
import platform
import sys
sys.dont_write_bytecode=True
if platform.system()!="Darwin":
	f=open("errors.log","a")
	sys.stderr=f
import shutil
import os
if os.path.exists(os.path.expandvars("%temp%\gen_py")):
	shutil.rmtree(os.path.expandvars("%temp%\gen_py"))
_log("Importing wx...")
import wx
_log("Creating wx.App...")
wx_app = wx.App(redirect=False)

_log("Importing speak...")
import speak
_log("Importing GUI.main (creates window)...")
from GUI import main
_log("Getting app instance...")
fastsm_app = get_app()
_log("Calling app.load()...")
fastsm_app.load()
_log("App loaded, showing window...")
if fastsm_app.prefs.window_shown:
	main.window.Show()
else:
	speak.speak("Welcome to FastSM! Main window hidden.")
_log("Starting main loop")
wx_app.MainLoop()
