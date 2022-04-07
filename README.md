# Install EGroupware via Docker
### First we install EGrouoware via docker than we transfer the files from the old Egroupware 16.9 to the new server.

```
rm -f InstallEGW.sh && curl -O https://raw.githubusercontent.com/agroviva/Install-EGroupware/main/InstallEGW.sh && bash InstallEGW.sh
```

# Reinstall Apps
### Reinstall third party apps like Zeiterfassung, CAO-Schnittstelle & ThreeCX
```
rm -f ReinstallApps.sh && curl -O https://raw.githubusercontent.com/agroviva/Install-EGroupware/main/ReinstallApps.sh && bash ReinstallApps.sh
```
