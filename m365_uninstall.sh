#!/bin/bash
# Define function to print colored text
print_color() {
  # Set the text color based on the first argument
  case "$1" in
    red)
      color_code="31m" ;;
    green)
      color_code="32m" ;;
    yellow)
      color_code="33m" ;;
    blue)
      color_code="34m" ;;
    *)
      color_code="0m" ;;
  esac
  # Print the colored text
  printf "\033[${color_code}${2}\033[0m\n"
}

# Get list of sites with "appcatalog" in the URL
sites=$(m365 spo site list -o json | jq '.[] | select(.Url | contains("appcatalog")) | .Url')
if [ -z "$sites" ]; then
  print_color red "No appcatalog sites were found.\n"
  print_color yellow "Checking DisableCustomAppAuthentication value...\n"
  if m365 spo tenant settings get | grep -q 'DisableCustomAppAuthentication": false,'; then
    m365 spo tenant settings set --DisableCustomAppAuthentication true
    print_color green "DisableCustomAppAuthentication was set to true.\n"
  else
    print_color yellow "DisableCustomAppAuthentication is already set to true.\n"
  fi
  exit 1
fi

# Print list of sites
echo "List of appcatalog sites:"
PS3="Select a site by number: "
select selected_site in $sites; do
  # Remove any quote marks and trailing slashes from the selected site
  selected_site=${selected_site%\"}
  selected_site=${selected_site#\"}
  selected_site=${selected_site%/}
  
  # Get ProductID for an app with "DLP Monitor" for the Title
  app=$(m365 spo app list -u "$selected_site" | jq '.[] | select(.Title == "DLP Monitor")')
  if [ -z "$app" ]; then
    print_color red "No app with the Title 'DLP Monitor' was found on the selected site."
  else
    product_id=$(echo "$app" | jq -r '.ProductId')
    print_color green "ProductID for app 'DLP Monitor' on selected site: $product_id"
  
    # Remove app
    echo "Removing $app with $product_id"
    if m365 spo app remove --id $product_id --appCatalogScope tenant --appCatalogUrl $selected_site --confirm; then
      print_color green "App 'DLP Monitor' was successfully removed from selected site."
    else
      print_color red "Failed to remove app 'DLP Monitor' from selected site."
    fi
  fi
  
  # Remove app catalog site
  echo "Removing app catalog site..."
  if m365 spo site appcatalog remove --siteUrl $selected_site; then
    print_color green "App catalog site was successfully removed from selected site."
    break
  else
    print_color red "Failed to remove app catalog site from selected site."
  fi
done

# Disable custom app authentication
echo "Disabling custom app authentication..."
if m365 spo tenant settings set --DisableCustomAppAuthentication true; then
  print_color green "Custom app authentication has been disabled."
else
  print_color red "Failed to disable custom app authentication."
fi

echo ""
print_color green "Script execution completed successfully." 
