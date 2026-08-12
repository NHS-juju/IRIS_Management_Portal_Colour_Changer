# IRIS_Management_Portal_Colour_Changer
Unofficial Powershell script to alter the header colour of Intersystems IRIS Instances 

## What it does

The script will:
- prompt the user for the path to `CSP/broker` for the environment
- prompt the user to either
  - Set the Management Portal Header colour to one of a number of options
    - If attempting to set the colour when there is already a backup detected in the directory, it will restore to the backup, recreate the backup, and then make the change again (wasteful logic, but a first draft)
  - Restore the environment to the original configuration from the backup file it creates

## How?

The script attempts to modify the file `ZEN_Component__core.js` in the installation location of IRIS on the Windows server the script is ran on to then point it at a second javascript file it creates which will run a single line of code to overwrite the default colour of the header bar

## Why

Although there are options available to differentiate between environments using configuration within the application, some people prefer a much less subtle visual reminder of the environment.

## Requirements

- access to the server IRIS is running on
- write access to the installation location of IRIS
- No fear

## Setup

1. Download the script to your machine
2. Run the script
3. Follow the prompts

## Notes

The script is based off of unsupported changes being made by various users (for example, [in the comments here](https://community.intersystems.com/post/system-mode-banner)). This script simply attempts to automate the steps other users are following, including taking a backup of the files being changed. As the time of writing, the newer releases of IRIS are undergoing a UI change, so this script could stop working, or may even stop being useful if the new UI includes features that replicate the same behaviour being sought by some users.

It is imperative that before running this script that you understand the changes being made and any risks to the actions within the script. You are ultimately responsible for running this within your environment, assume all responsibility for your own actions, and only you can stop forest fires.
