#!/bin/bash

# Variables
app_id=
filePath=$HOME/Downloads
fileName="SHN-DLP-Monitor.app"
fileNameGov="SHN-Security-Integrator-GovCloud.zip"
domain="yourdomain"
appName="SHN DLP Monitor"
appCatalog="$selected_site/sites/appcatalog"
connectedAs=
selected_site=
timezone_value=
disable_custom_app_auth=


# Function to output red text
print_red() {
  echo -e "\033[31m$1\033[0m"
}

# Function to output green text
print_green() {
  echo -e "\033[32m$1\033[0m"
}

# Check if user is logged in, and log in if necessary
if [[ $(m365 status) == *"Logged out"* ]]; then
    print_red "NOT currently logged in Microsoft 365." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.04; done; echo ""
    echo ""
    print_green "Logging in to Microsoft 365..." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.04; done; echo ""
    m365 login
else 
    echo ""
    print_green "Currently logged into M365 cli as:" | while IFS= read -n1 c; do echo -n "$c"; sleep 0.04; done; echo ""
    m365 status | grep -oE '"connectedAs":\s*"[^"]+"' | cut -d '"' -f 4
    echo ""
fi


# -------------------------------------
# Get list of sites
sites=$(m365 spo site list -o json | jq '.[].Url')

# Create array from sites
sites_array=()
while read -r line; do
    sites_array+=("$line")
done <<< "$sites"

# Print list of sites with numbering
echo "Select a site:"
for i in "${!sites_array[@]}"; do
    echo "$(($i+1)). ${sites_array[$i]}"
done
echo ""

# Prompt user to select a site
read -p "Enter site number: " site_number

# Check if site number is valid
if ! [[ "$site_number" =~ ^[1-${#sites_array[@]}]$ ]]; then
    echo "Invalid site number"
    exit 1
fi

echo ""

# Save selected site URL as a variable
selected_site="${sites_array[$((site_number-1))]}"

# Prompt user to confirm selection
read -p "Selected site: $selected_site. Is this correct? (y/n) " confirmation

echo ""

# Loop until user confirms selection
while [[ "$confirmation" != "y" ]]; do
    # Print list of sites with numbering
    echo "Select a site:"
    for i in "${!sites_array[@]}"; do
        echo "$(($i+1)). ${sites_array[$i]}"
    done
    
    # Prompt user to select a site
    read -p "Enter site number: " site_number
    
    # Check if site number is valid
    if ! [[ "$site_number" =~ ^[1-${#sites_array[@]}]$ ]]; then
        echo "Invalid site number"
        exit 1
    fi
    
    # Save selected site URL as a variable
    selected_site="${sites_array[$((site_number-1))]}"
    
    # Prompt user to confirm selection
    read -p "Selected site: $selected_site. Is this correct? (y/n) " confirmation
done

# Print selected site URL
echo "Selected site: $selected_site"

echo ""
# -------------------------------------

if [ -f "$HOME/Downloads/$fileName" ]; then
    print_green "$fileName found in $HOME/Downloads directory." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.05; done; echo ""
    echo ""
else
    print_red "$fileName NOT found in $HOME/Downloads directory." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.04; done; echo ""
    echo ""
    PS3="Please select an option: "
    options=("Enter file path" "Download $fileName for USPROD" "Download $fileName for US GovCloud" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Enter file path")
                read -p "Please enter the full file path to $fileName: " filePath
                while [ ! -f "$filePath" ]; do
                    read -p "Invalid file path. Please enter the full file path to $fileName: " filePath
                done
                break
                ;;
            "Download $fileName for USPROD")
                echo ""
                wget -cq "https://success.myshn.net/@api/deki/files/4697/SHN-DLP-Monitor.app?revision=2" -O "$filePath/SHN-DLP-Monitor.app"
                if [ -f "$filePath/SHN-DLP-Monitor.app" ]; then
                    print_green "$fileName downloaded to $filePath directory." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.05; done; echo ""
                else
                    echo "Error: $fileName not downloaded to $filePath directory."
                fi
                echo ""
                break
                ;;
            "Download $fileName for US GovCloud")
                wget -cq "https://success.myshn.net/@api/deki/files/7233/SHN-Security-Integrator-GovCloud.zip?revision=1" -O "$filePath/SHN-Security-Integrator-GovCloud.zip"
                if [ -f "$filePath/SHN-Security-Integrator-GovCloud.zip" ]; then
                    print_green "$fileNameGov downloaded to $filePath directory." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.05; done; echo ""
                else
                    echo "Error: $fileName not downloaded to $filePath directory."
                fi
                echo ""
                break
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
fi


# -------------------------------------
north_america_timezones=(
  "(GMT-05:00) Eastern Time (U.S. and Canada)"
  "(GMT-06:00) Central Time (U.S. and Canada)"
  "(GMT-07:00) Mountain Time (U.S. and Canada)"
  "(GMT-08:00) Pacific Time (U.S. and Canada)"
  "(GMT-09:00) Alaska"
  "(GMT-10:00) Hawaii"
)
north_america_values=(10 11 12 13 14 15)

central_america_timezones=(
  "(GMT-05:00) Eastern Time"
  "(GMT-06:00) Central Time"
)
central_america_values=(10 11)

south_america_timezones=(
  "(GMT-02:00) Mid-Atlantic"
  "(GMT-03:00) Buenos Aires, Georgetown"
  "(GMT-04:00) Caracas, La Paz"
  "(GMT-05:00) Bogota, Lima, Quito, Rio Branco"
  "(GMT-06:00) Central Time"
)
south_america_values=(30 32 33 35 37)

# prompt for region choice
echo "Please choose a region:"
echo "1) North America"
echo "2) Central America"
echo "3) South America"
read region_choice
echo ""

if ! [[ "$region_choice" =~ ^[1-3]$ ]]; then
  echo "Invalid region choice."
  exit 1
fi

# prompt for timezone choice based on region
if [[ "$region_choice" == "1" ]]; then
  timezones=("${north_america_timezones[@]}")
  values=("${north_america_values[@]}")
elif [[ "$region_choice" == "2" ]]; then
  timezones=("${central_america_timezones[@]}")
  values=("${central_america_values[@]}")
else
  timezones=("${south_america_timezones[@]}")
  values=("${south_america_values[@]}")
fi

echo "Please choose a timezone:"
for i in "${!timezones[@]}"; do
    echo "$(($i+1))) ${timezones[$i]}"
done
read selection
echo ""

if ! [[ "$selection" =~ ^[1-9][0-9]*$ ]] || (( selection > ${#timezones[@]} )); then
    echo "Invalid selection."
    exit 1
fi

timezone_value=${values[$(($selection-1))]}

echo "You selected ${timezones[$(($selection-1))]}, which has a value of $timezone_value./n"


# Create an SPO appcatalog site
m365 spo tenant appcatalog add -u "$appCatalog" --owner "$connectedAs" --timeZone $timezone_value --wait --force

if [ $? -eq 0 ]; then
  echo "$appCatalog successfully created./n"
else
  echo "Error occurred while creating $appCatalog./n"
fi

# Get the current value of DisableCustomAppAuthentication
disable_custom_app_auth=$(m365 spo tenant settings list | grep DisableCustomAppAuthentication | awk '{print $2}')

if [ -z "$disable_custom_app_auth" ]; then
  echo "Error: Unable to retrieve DisableCustomAppAuthentication value."
  exit 1
fi

# Check if the value is true
if [ "$disable_custom_app_auth" == "true" ]; then
  # Set the value to false
  m365 spo tenant settings set --DisableCustomAppAuthentication false
  if [ "$?" -eq 0 ]; then
    echo "DisableCustomAppAuthentication has been set to false./n"
  else
    echo "Error: Unable to set DisableCustomAppAuthentication value to false./n"
    exit 1
  fi
else
  echo "DisableCustomAppAuthentication is already false./n"
fi

# Check if the site collection app catalog already exists
if m365 spo site appcatalog get -u $appCatalog &>/dev/null; then
  echo "Site collection app catalog already exists./n"
else
  # Try to create the site collection app catalog
  if m365 spo site appcatalog add -u $appCatalog; then
    echo "Site collection app catalog has been created./n"
  else
    echo "Error creating site collection app catalog./n"
    exit 1
  fi
fi


# Adds an app to the specified SharePoint Online app catalog
app_id=$(m365 spo app add --filePath "$filePath/$fileName" --overwrite --output json | jq -r '.UniqueId')

# Check if the app_id is empty
if [[ -z "$app_id" ]]; then
  echo "Failed to add app to app catalog/n"
  exit 1
else
  echo "App added successfully with ID: $app_id/n"
fi


