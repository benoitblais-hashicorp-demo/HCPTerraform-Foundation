# Set up the GitHub.com OAuth VCS provider

> [!WARNING]
> Configuring a new VCS provider requires permission to manage VCS settings for the organization.

Connecting HCP Terraform to your VCS involves four steps:

| On your VCS | On HCP Terraform |
| --- | --- |
|     | Create a new connection in HCP Terraform. Get callback URL. |
| Register your HCP Terraform organization as a new app. Provide callback URL. |     |
|     | Provide HCP Terraform with ID and key. Request VCS access. |
| Approve access request. |     |

## Step 1: On HCP Terraform, begin adding a new VCS provider

1. Sign in to [HCP Terraform](https://app.terraform.io) or Terraform Enterprise and navigate to the organization where you want to add the VCS provider.

2. Choose **Settings** from the sidebar, then click Providers.

3. Click **Add a VCS provider**. The Add VCS Provider page appears.

4. Select **GitHub** and then select **GitHub.com (Custom)** from the menu. The page moves to the next step.

Leave the page open in a browser tab. In the next step you will copy values from this page, and in later steps you will continue configuring HCP Terraform.

## 2: On GitHub, create a new OAuth application

1. In a new browser tab, open [github.com](https://github.com/) and log in as whichever account you want HCP Terraform to act as. For most organizations this should be a dedicated service user, but a personal account will also work.

   > [!IMPORTANT]
   > The account you use for connecting HCP Terraform must have admin access to any shared repositories of Terraform configurations, since creating webhooks requires admin permissions.

2. Navigate to GitHub's [Register a New OAuth Application](https://github.com/settings/applications/new) page.

   This page is located at [https://github.com/settings/applications/new](https://github.com/settings/applications/new). You can also reach it through GitHub's menus:

   * Click your profile picture and choose "Settings."
   * Click "Developer settings," then make sure you're on the "OAuth Apps" page (not "GitHub Apps").
   * Click the "New OAuth App" button.

3. This page has a form with four text fields.

Fill out the fields with the corresponding values currently displayed in your HCP Terraform browser tab. HCP Terraform lists the values in the order they appear, and includes controls for copying values to your clipboard.

Fill out the text fields as follows:

| Field name | Value |
| --- | --- |
| Application Name | HCP Terraform `<YOUR ORGANIZATION NAME>` |
| Homepage URL | `https://app.terraform.io` (or the URL of your Terraform Enterprise instance) |
| Application Description | Any description of your choice. |
| Authorization callback URL | `https://app.terraform.io/<YOUR CALLBACK URL>` |

### Register the OAuth application

1. Click the "Register application" button, which creates the application and takes you to its page.

2. Leave this page open in a browser tab. In the next step, you will copy and paste the unique Client ID and Client Secret.

## Step 3: On HCP Terraform, set up your provider

1. Enter the **Client ID** and **Client Secret** from the previous step, as well as an optional **Name** for this VCS connection.

2. Click "Connect and continue." This takes you to a page on GitHub.com, asking whether you want to authorize the app.

3. The authorization page lists any GitHub organizations this account belongs to. If there is a Request button next to the organization that owns your Terraform code
repositories, click it now. Note that you need to do this even if you are only connecting workspaces or Stacks to private forks of repositories in those organizations
since those forks are subject to the organization's access restrictions. See [About OAuth App access restrictions](https://docs.github.com/en/organizations/managing-oauth-access-to-your-organizations-data/about-oauth-app-access-restrictions).

4. Click the green "Authorize `<GITHUB USER>`" button at the bottom of the authorization page. GitHub might request your password or multi-factor token to confirm the operation.
