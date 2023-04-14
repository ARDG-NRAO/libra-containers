# Roadrunner Singularity Container

The goal of this repo is to enable the production of a singularity based minimum dependency `roadrunner` application for development and testing across different NVIDIA GPUs and for easier shared development. At this juncture it is assumed that you have `singularity` installed on you machine of choice. If not please contact your sysadmin or refer to the ample documentation [available online](https://docs.sylabs.io/guides/3.11/user-guide/index.html)

## Building the container
In order to build the roadrunner container for development so you can make all your edits before shipping out for testing I prefer the `--sandbox` method. In order to build a `sandbox` which is essentially a linux container is a local folder, you can run the following.

```
singularity build --sandbox --fakeroot --fix-perms my_container_folder libra-cuda-11.4.0-devel-rockylinux8_readonly.def
```
The `--fakeroot` flag allows you root access within the container which we need to install the dependencies for development. The `--fix-perms` will allow you for you to remove the directory structure without needing higher privileges (sudo/su). 

## Running the code from within the container
The application can be used as an app or via the commandline. In order to access the application via commandline you can launch a `shell` inside the container as follows. This allows you to edit code and build the application once again should you need it
```
singularity shell --writable --fakeroot my_container_folder.
```

The `--fakeroot` is only needed if you want to add addtional packages you might need (such as an editor of choice). This will alter your prompt and should look like 
```
Singularity>
```

Within this shell you should be able to launch the `roadrunner` application with the command, however to bind the system nvidia runtime libraries you need to start a singularity shell as follows
```
singularity shell --nv my_container_folder
Singularity> /libra/apps/src/roadrunner
```
This should result in a commandline interface to the `roadrunner` application. By default the path from which you launched the container would be bound inside the container. If you want to bind additional paths to run code you can do it as follows
```
singularity shell --nv my_container_folder --bind host_path:continer_path
```

## Running the roadrunner app from within singularity
```
singularity run --nv --app roadrunner my_container_folder
```
Would let you run and interact with the application as if it were natively run on your machine while being deployed from within the container. Other such apps will be made available in this manner going forward.