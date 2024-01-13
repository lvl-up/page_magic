FROM mcr.microsoft.com/devcontainers/ruby:1-3.2-bullseye

RUN apt-get update -y && apt-get install -y chromium chromium-driver vim

RUN sudo -u vscode bash -l -c 'gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB'

RUN sudo -u vscode bash -l -c 'curl -sSL https://get.rvm.io | bash -s stable'
