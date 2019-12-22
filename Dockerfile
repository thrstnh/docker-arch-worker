from archlinux/base

MAINTAINER Thorsten Hillebrand <thrstn.hllbrnd@gmail.com>

USER root

# Refresh the keyring
RUN pacman-key --init \
 && pacman-key --populate archlinux \
 && pacman-key --refresh-keys

# Optimise the mirror list
RUN pacman --noconfirm -Syyu \
 && pacman-db-upgrade \
 && pacman --noconfirm -S reflector rsync \
 && reflector -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist \
 && pacman -Rsn --noconfirm reflector rsync

# Update system
RUN pacman -Su --noconfirm

# Install software
RUN pacman -Sy --noconfirm \
  base-devel \
  nmap \
  python python-pip python-setuptools

# Install python libraries
RUN pip install --upgrade pip setuptools wheel tox pbr

# Update db
RUN pacman-db-upgrade

# Remove orphaned packages
RUN if [ ! -z "$(pacman -Qtdq)" ]; then \
      pacman --noconfirm -Rns $(pacman -Qtdq); \
    fi

# Clear pacman caches
RUN yes | pacman --noconfirm -Scc

# Housekeeping
RUN rm -f /etc/pacman.d/mirrorlist.pacnew \
 && if [ -f /etc/systemd/coredump.conf.pacnew ]; then \
      mv -f /etc/systemd/coredump.conf.pacnew /etc/systemd/coredump.conf ; \
    fi \
 && if [ -f /etc/locale.gen.pacnew ];  then \
      mv -f /etc/locale.gen.pacnew /etc/locale.gen ; \
    fi

# Generate locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && echo "LANG=en_US.UTF-8" >> /etc/locale.conf
ENV LANG=en_US.UTF-8
