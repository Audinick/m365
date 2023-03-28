#!/bin/bash

# Variables
filePath=$HOME/Downloads/SHN-DLP-Monitor.app
domain="yourdomain"
appName="SHN DLP Monitor"

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
    #echo "Not currently logged into Microsoft 365..."
    echo "Logging in to Microsoft 365..."
    m365 login
else 
  echo ""
  print_green "Currently logged into m365 cli." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.05; done; echo ""
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
if [ -f "$HOME/Downloads/SHN-DLP-Monitor.app" ]; then
    print_green "SHN-DLP-Monitor.app found in $HOME/Downloads directory." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.05; done; echo ""
    echo ""
else
    print_red "SHN-DLP-Monitor.app NOT found in $HOME/Downloads directory." | while IFS= read -n1 c; do echo -n "$c"; sleep 0.04; done; echo ""
    echo ""
    read -p "Please enter the full file path to SHN-DLP-Monitor.app: " filePath
    # Check if the entered file path is valid
    while [ ! -f "$filePath" ]; do
        read -p "Invalid file path. Please enter the full file path to SHN-DLP-Monitor.app: " filePath
    done
fi

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

if ! [[ "$selection" =~ ^[1-9][0-9]*$ ]] || (( selection > ${#timezones[@]} )); then
    echo "Invalid selection."
    exit 1
fi

selected_value=${values[$(($selection-1))]}

echo "You selected ${timezones[$(($selection-1))]}, which has a value of $selected_value."
