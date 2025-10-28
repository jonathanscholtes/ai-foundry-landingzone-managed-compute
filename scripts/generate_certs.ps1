
$rootCert = New-SelfSignedCertificate -Type Custom -Subject "CN=P2SRootCert" `
    -KeySpec Signature -KeyExportPolicy Exportable `
    -KeyUsage CertSign -KeyUsageProperty Sign `
    -KeyLength 2048 -HashAlgorithm sha256 `
    -NotAfter (Get-Date).AddMonths(24) `
    -CertStoreLocation "Cert:\CurrentUser\My"


$rootCertData = [Convert]::ToBase64String($rootCert.RawData)


$clientCert = New-SelfSignedCertificate -Type Custom -Subject "CN=P2SClientCert" `
    -DnsName "P2SClientCert" `
    -KeySpec Signature -KeyExportPolicy Exportable `
    -KeyLength 2048 -HashAlgorithm sha256 `
    -NotAfter (Get-Date).AddMonths(18) `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $rootCert `
    -TextExtension @('2.5.29.37={text}1.3.6.1.5.5.7.3.2')


$clientCertPath = "certs\P2SClientCert.pfx"
$P2SClientCert = Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$($clientCert.Thumbprint)" `
    -FilePath $clientCertPath -Password (ConvertTo-SecureString -String "YourPassword" -Force -AsPlainText)


Write-Output $rootCertData
