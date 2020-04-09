terraform {
    # there are different backends that you can use if you don't have artifactory in your org.
    # https://www.terraform.io/docs/backends/types/index.html
    backend "artifactory" {
        username = "your_user_name"
        password = "your_password"
        url      = "your_artifacotry_url"
        repo     = "your_repo_name"
        subpath  = "your_subpath_name"
    }
}