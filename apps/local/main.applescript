on run
	runHelper({})
end run

on open droppedItems
	set droppedPaths to {}
	repeat with droppedItem in droppedItems
		set end of droppedPaths to POSIX path of droppedItem
	end repeat
	runHelper(droppedPaths)
end open

on runHelper(droppedPaths)
	set helperCommand to "/usr/bin/nohup " & quoted form of helperPath()
	repeat with droppedPath in droppedPaths
		set helperCommand to helperCommand & " " & quoted form of droppedPath
	end repeat

	try
		do shell script helperCommand & " >/dev/null 2>&1 &"
	on error errorMessage number errorNumber
		if errorNumber is not -128 then
			do shell script "/usr/bin/logger -t OpenRemoteDesktopApplet " & quoted form of ("helper exited " & errorNumber & ": " & errorMessage)
		end if
	end try
end runHelper

on helperPath()
	set appBundlePath to POSIX path of (path to me)
	return appBundlePath & "Contents/MacOS/Open Remote Desktop"
end helperPath
