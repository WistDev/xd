# 0. Minimizar todo
$shell = New-Object -ComObject Shell.Application
$shell.MinimizeAll()
Start-Sleep -Seconds 1

# Importar funciones de la API de Windows
$Signature = @"
[DllImport("user32.dll")]
public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
[DllImport("user32.dll")]
public static extern bool IsWindow(IntPtr hWnd);
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
$WinAPI = Add-Type -MemberDefinition $Signature -Name "WinAPI" -Namespace Win32Functions -PassThru

$url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
$handles = New-Object System.Collections.Generic.List[IntPtr]

# Función para abrir una ventana y capturar su Handle
function Abrir-Rick($cantidad) {
    for ($i = 1; $i -le $cantidad; $i++) {
        Start-Process "msedge" -ArgumentList "--new-window $url"
        Start-Sleep -Seconds 1.5
        $newWindows = Get-Process msedge | Where-Object { $_.MainWindowHandle -ne 0 -and -not $handles.Contains($_.MainWindowHandle) }
        foreach ($w in $newWindows) { $handles.Add($w.MainWindowHandle) }
    }
}

# Configuración inicial (7 ventanas)
Abrir-Rick 7

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$w = 450 
$h = 350 

Write-Host "MODO HYDRA ACTIVADO: Si cierras una, nacen dos." -ForegroundColor Red -BackgroundColor Black

# Bucle principal
while($true) {
    # Usamos una copia de la lista para poder modificar la original mientras iteramos
    $copiaHandles = $handles.ToArray()

    foreach ($handle in $copiaHandles) {
        # Verificar si la ventana aún existe
        if (-not $WinAPI::IsWindow($handle)) {
            Write-Host "¡Ventana cerrada! Aplicando protocolo Hydra..." -ForegroundColor Yellow
            $handles.Remove($handle) | Out-Null
            Abrir-Rick 2 # Abrir dos nuevas
            continue
        }

        # Movimiento aleatorio
        $WinAPI::ShowWindow($handle, 1)
        $posX = Get-Random -Minimum 0 -Maximum ($screen.Width - $w)
        $posY = Get-Random -Minimum 0 -Maximum ($screen.Height - $h)
        $WinAPI::SetWindowPos($handle, [IntPtr]::Zero, $posX, $posY, $w, $h, 0x0040)
    }
    
    Start-Sleep -Milliseconds 40
}