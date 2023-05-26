
function networkDirectory {
    do {
        $networkMask = Read-Host "Introduce la máscara de red"
        if ($networkMask -lt 0 -or $networkMask -gt 32) {
            Write-Host "La máscara de red '$networkMask' no es válida."
        }
        else {
            $validNetworkMask = $true
            Write-Host "Máscara de red válida."
        }
    } while (-not $validNetworkMask)

    do {
        $networkAddress = Read-Host "Introduce la dirección de red (formato: x.x.x.x)"
        $addressParts = $networkAddress -split '\.'
        $validAddress = $true

        # Validación de partes vacías/nulas
        foreach ($part in $addressParts) {
            if ([string]::IsNullOrEmpty($part)) {
                $validAddress = $false
                break
            }
        }

        # Validación de la dirección de red según la máscara
        $networkMaskBits = $networkMask -as [int]
        $validNetworkAddress = $validAddress -and ($networkMaskBits -eq 0 -or ($networkMaskBits -ne 0 -and $networkMaskBits -le 32))

        # Validación según las reglas de IPv4 y el numeric dot-decimal position
        if ($validNetworkAddress) {
            for ($i = 0; $i -lt $addressParts.Length; $i++) {
                $partValue = [int]$addressParts[$i]
                if ($i -lt [math]::Ceiling($networkMaskBits / 8.0)) {
                    if ($partValue -ne 255) {
                        $validNetworkAddress = $false
                        break
                    }
                }
                else {
                    if ($partValue -ne 0) {
                        $validNetworkAddress = $false
                        break
                    }
                }
            }
        }

        if (-not $validNetworkAddress) {
            Write-Host "La dirección de red '$networkAddress' no es válida según la máscara de red '$networkMask'."
        }
        else {
            Write-Host "Dirección de red válida."
        }
    } while (-not $validNetworkAddress)
}

# Para la máscara de red
# Si es 0 o menor de 8 comprobar todos los campos
# Si está entre 8 y 16 solo compruebe el 2do campo en adelante en bits (campo 3 y 4 "000")
# Si está entre 16 y 24 solo compruebe el 3er campo en adelante en bits (campo 4 "000")
# Si está entre 24 y 31 solo compruebe el 4to campo en bits

function userPasswdVM {
    # Usuario y contraseña
    do {
        try {
            $user = Read-Host "Introduce el nombre de usuario"

            if ([string]::IsNullOrEmpty($user)) {
                throw "El nombre de usuario no puede estar vacío."
            }
            elseif ($user -match "\s") {
                throw "El nombre de usuario no puede contener espacios."
            }
            elseif ($user -match "\d") {
                throw "El nombre de usuario no puede contener números."
            }
            elseif ($user -match "[^\w\-\.]") {
                throw "El nombre de usuario puede contener estos caracteres especiales: ['-', '_', '.']."
            }
            elseif ($user.ToLower() -in @("root", "admin", "administrador")) {
                throw "El nombre de usuario no puede ser 'root', 'admin' o 'administrador'."
            }
            elseif ($user.Length -lt 4) {
                throw "El nombre de usuario debe contener al menos 4 caracteres."
            }
            else {
                $validUser = $true
            }
        }
        catch {
            Write-Host "Debe completar el campo para continuar."
        }
    } while (-not $validUser)

    do {
        try {
            $passwdSecure = Read-Host "Introduce la contraseña" -AsSecureString
            $passwdSecureCheck = Read-Host "Confirma la contraseña" -AsSecureString

            $passwdVM = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwdSecure))
            $passwdCheck = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwdSecureCheck))

            if ([string]::IsNullOrEmpty($passwdVM) -or [string]::IsNullOrEmpty($passwdCheck)) {
                throw "La contraseña no puede estar vacía"
            }
            elseif ($passwdVM.Length -lt 4) {
                throw "La contraseña debe contener al menos 4 caracteres"
            }
            elseif ($passwdVM -ne $passwdCheck) {
                throw "Las contraseñas no coinciden"
            }
            elseif ($passwdVM -match "\s") {
                throw "La contraseña no puede contener espacios"
            }
            elseif ($passwdVM -match "^\w\.") {
                throw "La contraseña solo puede contener el carácter '.'"
            }
            else {
                $validPasswd = $true
            }
        }
        catch {
            Write-Host "Debe completar el campo para continuar."
        }
    } while (-not $validpasswd)
    return $user, $passwdVM
}

function vmCreation{
    # Nombre VM
    do {
        $vmName = Read-Host "Introduce el nombre de la máquina virtual a crear"
        try {
            if ([string]::IsNullOrEmpty($vmName)){
                throw "No puede estar vacío."
            }
            elseif ($vmName -match "^\W"){
                throw "No puede contener caracteres especiales."
            }
            else{
                $validName = $true
            }   
        }
        catch {
            Write-Host "Debe completar el campo para continuar."
        }
    } while (-not $validName)

    # Memoria RAM VM
    do {
        
        try {
            [int]($memory) = Read-Host "Introduce la cantidad de memoria RAM en MB (por ejemplo, 2048 para 2 GB)"
            if ([int]::IsNullOrEmpty($memory)) {
                throw "No puede estar vacío."
            }
            if (($memory -lt 512) -or ($memory -gt 32.000)){
                throw "Tiene que tener una memoria RAM mínima de 512MB, y una memoria RAM no superior a los 32GB."
            }
            else{
                $validRam = $true
            }
        }
        catch {
            Write-Host "Debe completar el campo para continuar."
        }
    } while (-not $validRam)

    # Espacio en memoria VM
    do {
        [int]($diskSize) = Read-Host "Introduce el espacio en memoria que tendrá el disco duro (en MB)"
        try {
            if ([int]::IsNullOrEmpty($diskSize)) {
                throw "No puede estar vacío."
            }
            if (($diskSize -lt 20.000)){
                throw "Tiene que tener un espacio mínimo de 20GB(20.000)."
            }
            else{
                $validSpace = $true
            }
        }
        catch {
            Write-Host "Debe completar el campo para continuar."
        }
    } while (-not $validSpace)
}

function vmOS{
    do {
        [int]($optionOS) = Read-Host "Seleccione un sistema operativo para su máquina virtual:
    1.- Windows 10
    2.- Windows 11  
    3.- Debian_x64
    4.- Ubuntu_x64"
    try {
        if ([int]::IsNullOrEmpty($optionOS)){
            throw "El campo no debe estar vacío."
        }
    }
    catch {
        Write-Host "Debe selectionar una de las opciones."
    }
    }
    while (-not $validSystem)
}

function vmScriptCreator{
    # Controladores IDE y SATA (SALTARLO al pedirlo)
    [string]($sataName) = "SATA Controller"
    [string]($sataControl) = "sata"

    [string]($ideName) = "IDE Controller"
    [string]($ideControl) = "ide"

    # Memoria de vídeo (Diferente en Windows y Linux)

    # Habilitar USB

    # Crear la máquina virtual
    VBoxManage createvm --name $vmName --ostype $OS_Type --register

    # Configurar la memoria RAM
    VBoxManage modifyvm $vmName --memory $memory

    VBoxManage createmedium disk --filename="$VM_HOME\$vmName\$vmName.vdi" --size=$disk_Size --format VDI

    # Crear y asignar el disco duro a la máquina virtual
    VBoxManage storagectl $vmName --name=$disk_Controller_Name --add $disk_Controller_Type --bootable on
    VBoxManage storageattach $vmName --storagectl=$disk_Controller_Name --port 0 --device 0 --type hdd --medium="$VM_HOME\$vmName\$vmName.vdi"

    VboxManage unattended install $vmName --iso=$iso_VM --user=$user_VM --password=$passwd_VM --full-user-name=$full_user_VM --locale=$locale_VM --country=$country_VM --language=$lang_VM --hostname=$host_VM

}

#networkDirectory

<#
$RedNat_IPv4 = Read-Host "Introduce la dirección de red que va a tener"
$a = $RedNat_IPv4.Split(".")
    if ($a.Length -eq 4){
            for ($i = 0; $i -lt 4; $i++) {
                if ($a[$i] -match '\d') {
                    if ([int]$a[$i] -gt 255 ){
                        Write-Host "Error, el número introducido es mayor que 255."
                    }
                }
                else {
                    Write-Host "Error, la dirección de red solo puede contener números."
                    break
                }
                Write-Host $a[$i]
        }
    }
    else {
        Write-Host "Error, la dirección de red debe ser del tipo x.x.x.x"
    }
#>