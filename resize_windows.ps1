# Load necessary assembly
Add-Type -AssemblyName System.Windows.Forms

# Log all current process names to console
# Get-Process | Select-Object -Property ProcessName | ForEach-Object { Write-Host $_.ProcessName }

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
    if ($type::IsIconic($hwnd)) { $type::ShowWindow($hwnd, 9) }

    # Move and resize the window
    $type::MoveWindow($hwnd, $x, $y, $width, $height, $true)
}

# Get screen dimensions
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$totalWidth = $screen.Width
$totalHeight = $screen.Height

# Set window positions and sizes
Set-Window -processName "DB Browser for SQLite" -x 0 -y 0 -width ($totalWidth * 0.7) -height $totalHeight
Set-Window -processName "chrome" -x ($totalWidth * 0.7) -y 0 -width ($totalWidth * 0.3) -height $totalHeight
