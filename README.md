NOTE: This isn't in a publicly viable state yet, a lot of the dependencies are still private, and less than half-baked.

# site-spin

Site-Spin is a toolset for managing static website content hosted on AWS infrastructure managed using the website-stack toolset. This project builds a docker image that a content manager can use to build, preview, and publish content. It wraps the [Jekyll](https://jekyllrb.com/) static website generator into the docker image, with all of its dependencies, along with some helper scripts.

The goals of using this toolset are:
1. Minimize what you need to install and configure on your local machine in order to work with your website's content,
2. Provide a consistent local working environment for multiple people to work on the website's content,
3. Enable a pipeline workflow for publishing the website content to multiple environments, for example for testing, staging, and signoff of content changes.

An underlying driver for this project is to demonstrate the use of the spin-stack framework for managing infrastructure.

Site-Spin uses [dojo](https://github.com/kudulab/dojo) to build and run docker images locally. It assumes the use of [website-stack](https://github.com/kief/website-stack) for managing website hosting infrastructure, which in turn is based on [spin-tools](https://github.com/kief/spin-tools).

Tested and released images are published to dockerhub as [kiefm/site-spin](https://hub.docker.com/r/kiefm/site-spin)


# How-to guides

The following guides are needed:

- As a content manager, I want to work with the content of a website that uses site-spin, so I can edit and publish content
- As a website manager, I want to set up a new website using site-spin, so I can start creating and publishing content
- As a developer, I want to work on the site-spin codebase, so I can contribute changes to the project


## HOW TO: Prerequisites for the other how tos.

1. Docker. I use colima to install it on my Mac. Make sure you're running it to expose network ports (with colima, start it with the command  `colima start --network-address`).
2. [Dojo](https://github.com/kudulab/dojo) (I install it on my Mac with homebrew)



## HOW TO work with the content of a website that uses site-spin

Follow the prerequisites first.

### 1. Clone the website content project locally

git clone the project repo.


### 2. Edit, build, and preview the site

Aside from adding, editing, and viewing the content files, here are commands for working locally:

|| build | Generate the static website with published content only
|| preview | Generate the website including unpublished content and host it locally on http://localhost:4000
|| ready | Generage the website with published content only and host it locally on http://localhost:4000
|| jekyll <commands> | Run jekyll commands


When you're happy with the content, you will normally commit and push the code, and the pipeline will kick in. Here are commands that should run in the pipeline, and that you may be able to run locally for debugging and development purposes.

Build stage:

|| build | Generate the static website with published content only
|| package | Prepare the static website files for publication, giving them a version number. Ideally, this is an "immutable" package, in that the content isn't changed for different instance of the site. (In practice, jekyll may expect to build it differently depending on the URL?)
|| upload | Upload the versioned website content package to a repository so it can be published to website instances (environments).

Publication stages:

|| publish | Synchronize a versioned website content package to a website instance (environment), hosted on AWS infrastructure managed with [website-stack](https://github.com/kief/website-stack). In practice, this is an S3 bucket, so doesn't necessarily need to be created with website-stack.



## HOW TO set up a new website to use site-spin

Follow the prerequisites first.

### 1. Create a project for the website content project

Make it a github project. Make a folder called `content`.


### 2. Create a Dojofile in the root of the project folder

```
DOJO_DOCKER_IMAGE="kiefm/site-spin:latest"
DOJO_DOCKER_OPTIONS="-p 4000:4000"
```

Run `dojo`, which should download the site-spin docker image and run an instance, putting you at the command prompt at the working directory `/dojo/work`.


### 3. Set up the website

This is jekyll stuff. Best to do this in the `content` subfolder, so other folders can be used for environment configuration and other stuff.



## HOW TO make changes to and build this toolset

Follow the prerequisites first.


TODO
