 ![##Images_README_Splash##](./img/splash.png)

# **Ark API PowerShell Module**

All-in-one module to access all Ark network functions using PowerShell in Windows 7, 8, 10 and Windows Server 2008R2, 2012, 2016. This module will include integrated Help and Examples in v1.0.  It's a "Work In Progress" toward v1.0. It's very incomplete compared to full Ark API possibilities ...

To support development, vote gr33ndrag0n on Ark network for Delegate or become a sponsor on my website.

Visit [Ark.io](https://www.ark.io) for official Ark related stuff ...

Visit [ArkNode.net](https://www.arknode.net) for more community Ark related stuff and my donation address ...

##**Installing the module**

Download and Extract zip file to a work directory.

For example, `C:\GIT\PsArk`

Make a copy of the PsArk sub-directory `C:\GIT\PsArk\PsArk`

In the PSModulePath directory: `C:\Program Files\WindowsPowerShell\Modules\`

You should have: `C:\Program Files\WindowsPowerShell\Modules\PsArk\`

##**Using the module**
####**Loading Module**
To access the module cmdlets you first need to load it in memory using:
> Import-Module PsArk

####**Check Available Cmdlets**
Once the module is loaded, you can list all available cmdlets using:
> Get-Command \*PsArk*

####**View Help and Usage Example of a given cmdlet.**
Warning: Help might not exist for all cmdlets until release of v1.0.
> Get-Help CommandName -Full

Example:
> Get-Help Set-PsArkConfiguration -Full

##**Extra Scripts**

I included some examples usage scripts in the `Scripts` sub-directory of the archive.

##**Text Based Documentation**

For thoses who prefer using text files documentation, I auto-generated it and included it in the `Documentation` sub-directory of the archive.

##**Troubleshooting & Common Error(s)**

**It doesn’t work.**

Verify PowerShell version installed in your computer. Execute the following command:

> $PSVersionTable

The PSVersion must be at least v4.x.
If not, go [HERE](https://www.microsoft.com/en-us/download/details.aspx?id=40855), select your language, download, install and reboot.

When done re-run the test to confirm your version is now v4.x or upper.

**Script work but communication with server fail.**

Verify the configuration of the server (config.json) to allow your IP address in the whitelist section. Don’t forget to restart your Ark client to update the configuration.

**Script is asking confirmation to execute when running it.**

>Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
