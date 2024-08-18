#################################################################################################################
# Block_Twitter_Followers_Or_Hashtag_VX.Y.ps1 - Block the followers of a Twitter user OR block all the Twitter
# users that have a specific hashtag in their posts (I.e. using the Search box)
#
# Kudo's to the "Block button for X(Twitter)" extension that popped up the URL for blocking users. This extension
# gave me tips on how to script this out:
# chrome://extensions/?id=mfoeckbmbmmifpgdlokmionbblpbcbfh
# And to the idea from Twitter Blocker for writing a script:
# https://outsidetheasylum.blog/twitter-blocker/
# 
# Input - HTML from Twitter that shows the feed
#
# Output - A JavaScript to block all those users
# 
# Instructions:
# 
#
# Version 1.0 - Initial
#################################################################################################################
# Intialize the input to null
$inputString = ""

# Read in all the HTML from the "Inspect" that includes either the followers OR the users that use the hashtag you want to block
do {
	$input = Read-Host "Enter input (end with a period '.')"
	if ($input -ne ".") {
		$inputString += $input + "`n"
			}
# After pasting input a "." on a blank line to continue
} while ($input -ne ".")

$pattern_follow = 'href.{0,50}follow|follow.{0,50}href'
$follow_input = $inputstring -match $pattern_follow
if ($follow_input) {Write-Host "Input HTML appears to be a 'Follow' list"
# Look for "Follow" followed by a username and add that username to the matches string
	$pattern = 'Follow @[^"]*"'
	$matches = [regex]::Matches($inputString, $pattern)
# Remove the last three users as those are typically "Here are some suggested users to follow" and they may
# actually be users you WANT to follow
	$matches = $matches | Select-Object -First ($matches.Count - 3)
# Update each user string to include the "block" request
	$cleanedStrings = foreach ($match in $matches) {
				$match.Value -replace '^Follow @', 'https://x.com/' -replace '"$', '?block=true'
			}
	}

$pattern_query = 'href.{0,100}typed_query|typed_query.{0,100}href'
$query_input = $inputstring -match $pattern_query
if ($query_input) {Write-Host "Input HTML appears to be a 'Query' list"
# Look for "data-username" followed by a username and add that username to the matches string
	$pattern = 'data-username="@[^"]*"'
	$matches = [regex]::Matches($inputString, $pattern)
# Update each user string to include the "block" request
$cleanedStrings = foreach ($match in $matches) {
			$match.Value -replace '^data-username="@', 'https://x.com/' -replace '"$', '?block=true'
			}
	}

if (!($query_input -or $follow_input)) {Write-Host "Not HTML from a Follow or from a query. No output generated"}
else {
# Create the final Javacript that needs to be run
	$finalString = $cleanedStrings -join "','"
	$finalString = "const urls = [ '" + $finalString + "']; urls.forEach(url => {  window.open(url, '_blank'); });"
	}

Write-Host "Paste the following into the bottom right "Console" Window:'r"

Write-Host $finalString


