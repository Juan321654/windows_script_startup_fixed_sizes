# Load necessary assembly
Add-Type -AssemblyName System.Windows.Forms

# Must match the name of the program's window
$program1Name = "DB Browser for SQLite"   # Name of the first program
$program2Name = "chrome"                  # Name of the second program

# Window size and position percentages
$program1WidthPercentage = 0.7   # Percentage width for Program 1 window
$program2WidthPercentage = 0.3   # Percentage width for Program 2 window
$windowHeightPercentage = 1.0    # Full height for both windows

# Window position variables
$startPositionXProgram1 = 0      # Start X position for Program 1 window
$startPositionY = 0              # Start Y position for all windows

# Calculate the screen dimensions and positions
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$totalWidth = $screen.Width
$totalHeight = $screen.Height

# Calculate widths for each window based on screen width and specified percentages
$widthProgram1 = [int]($totalWidth * $program1WidthPercentage)
$widthProgram2 = [int]($totalWidth * $program2WidthPercentage)
$height = [int]($totalHeight * $windowHeightPercentage)

# Program 2's X start position should be right after Program 1 window
$startPositionXProgram2 = $widthProgram1

# Function to set window position and size
function Set-Window {
    param (
        [string]$processName,
        [int]$x,
        [int]$y,
        [int]$width,
        [int]$height
    )

    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue | Select-Object -First 1
    if (!$process) {
        Write-Host "Process $processName not found."
        return
    }

    $hwnd = $process.MainWindowHandle
    if ($hwnd -eq 0) {
        Write-Host "Main window handle for $processName not found."
        return
    }

    $sig = '
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool IsZoomed(IntPtr hWnd);
    '
    $type = Add-Type -MemberDefinition $sig -Name Win32SetWindowPos -Namespace Win32Functions -PassThru

    # Restore the window if minimized
    $swRestore = 9  # Command to restore a minimized window
    if ($type::IsIconic($hwnd)) { $type::ShowWindow($hwnd, $swRestore) }

    # Move and resize the window
    $type::MoveWindow($hwnd, $x, $y, $width, $height, $true)
}

# Set window positions and sizes for both programs
Set-Window -processName $program1Name -x $startPositionXProgram1 -y $startPositionY -width $widthProgram1 -height $height
Set-Window -processName $program2Name -x $startPositionXProgram2 -y $startPositionY -width $widthProgram2 -height $height
