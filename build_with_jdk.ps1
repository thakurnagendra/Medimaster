# Set JAVA_HOME to the installed JDK location
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.10.7-hotspot"
Write-Host "JAVA_HOME set to: $env:JAVA_HOME"

# Add Java bin to PATH
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
Write-Host "Added Java bin to PATH"

# Run Flutter build
Write-Host "Running Flutter build..."
flutter build apk --debug
