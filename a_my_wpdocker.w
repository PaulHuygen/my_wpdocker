m4_include(inst.m4)m4_dnl
\documentclass[11pt,twoside]{artikel3}
\newcommand{\theTitle}{m4_doctitle}
\newcommand{\theAuthor}{m4_author}
\input{thelatexheader.tex}
\begin{document}
\maketitle
\tableofcontents
\begin{abstract}
This document generates a Docker image that contains te Wordpress
website of CLTL.nl. It is derived from a back-up fom the actual
website.   

\end{abstract}

\section{Introduction}
\label{sec:introduction}

This document constructs a restoration of a Wordpress website from a
back-up. A Docker image with the restoration of the site is made. It
serves the following purposes:

\begin{enumerate}
 \item Provide proof that the back-up is complete. In other words, it is
   guaranteed that, if a disaster happens, the website can be
   restored.
 \item Describe how it works. After a while, the knowledge on how to
   use the software instruments for the restoration becomes
   rusty. Hopefully this document provides clear instructions.
 \item The software on the original site has not been updated for a
   long time. When a Docker with a duplicate exists, this can serve as
   a template to test upgrading.
\end{enumerate}

\subsection{Tasks to be performed}
\label{sec:tasks}

First we have to do the following:

\begin{enumerate}
\item Construct a solid back-up procedure.
\item Construct a back-up procedure for the server that runs the
  website. The information on the back-up is the basis for the
  restored image.
\item Construct a Docker image with the correct version of the
  operating system on it. The original server uses a very old version
  of Ubuntu linux: \texttt{m4_long_ubuntuversion}.
\item Install the database and restore the WordPress part on it.
\item Install the Apache web-server.
\item Restore the WordPress site. This is of a very old version too.
\item Test whether it works.
\end{enumerate}

When this works, we will bother about upgrading the operating system
and Wordpress to the latest version.

Basically it works as follows: A script \verb|doit| translates the
Nuweb sources. The Nuweb sources produce a Dockerfile and an
installation script. The Dockerfile is used to generate a Docker image
based on the correct version of Ubuntu. In the image the installation
script has to be started manually, because several operations require
manual interventions that I don't know how to surpass.

The installation script installs Mysql and loads the Wordpress
database in it. 

This is the script \verb|doit|.  It has four parts:
\begin{enumerate}
\item Preliminaries: Make sure that everything that is needed is
  available.
\item Generate the scripts from the Nuweb source.
\item Build the Docker image.
%\item Run the docker image.
\end{enumerate}

@o doit @{@%
#!/bin/bash
# doit -- generate the image
@< preliminary checks @>
make sources
@< make scripts executable @>
@< build the Docker image @>
@| @}


\section{Preliminaries}
\label{preliminaries}

In order to be able to run the \textsc{cltl} website, the Docker image
needs several resources, e.g.{} a dump of the orinal Wordpress
database. Put these resources in a ``transfer directory'' and copy
that directory into the new image. 

@d preliminary checks @{@%
mkdir -p transferdir
@| @}

Some of the resources are secret, e.g. passwords. Therefore they
cannot be shared on e.g. Github. Write the secrets in a file
\verb|secrets| and put it in the transfer directory. 

@d preliminary checks @{@%
if
  [ ! -e "transferdir/secrets" ]
then
  cp ../.my_secrets/secrets transferdir/ 2>/dev/null
  if
    [ $? .gt. 0 ]
  then
    echo "File with secrets not present"
    exit 1 
  fi
fi
@| @}

To help you, generate a "template" script, that looks like the real
script but with fake information in it.

@o secret_template @{@%
@< password stuff @>
@| @}


If all is well, a directory with a partial back-up of the original cltl website server has been mounted on \texttt{m4_backup_mountpoint}. Let's check that out.

@d preliminary checks @{@%
if
  [ ! -e "m4_backup_mountpoint/root" ]
then
  echo "back-up directory b2l has not been mounted."
  exit 1 
fi
@| @}



\section{Construct the docker image}
\label{sec:construct-docker}

The following rudimentary Dockerfile generates an image for an Ubuntu
14.04 server. After you run the image, you can contact it via the
terminal. When you stop it, all modifications are lost.

@o Dockerfile @{@%
FROM m4_docker_template
EXPOSE m4_expose_port
@< copy stuff to the image @>
@< ``run'' commands in Dockerfile @>
CMD ["/bin/bash"]
@| @}

@d copy stuff to the image @{@%
COPY transferdir /root/transferdir/
@| @}


@d build the Docker image @{@%
docker build -t m4_docker_image .
@| @}

To restore the Wordpress-site on the image, \texttt{run} a script with
instructions. Load the secret information into this script.

@o restore @{@%
#!/bin/bash
source /root/transferdir/secrets
@< restore instructions @>
@| @}

@d copy stuff to the image @{@%
COPY --chmod=775 restore /root/restore 
@| @}

We would like to eventually install debian packages. So, let us first
prepare for that. I could not yet find a way to do this automatically,
without manual intervention. So, after generation of the image, the
user has to run it, get access to it and start the \verb|restore|
script manually.

When we are at it, let us also install packages that we know we will need later on: sshfs, mysql, php, apache2.

@d restore instructions @{@%
apt-get update
apt-get upgrade
apt-get install sshfs apache2 mysql-common mysql-server php5-mysql php5-cli libapache2-mod-php5
@|sshfs apache2 mysql-common mysql-server php5-mysql php5-cli libapache2-mod-php5 @}

Analysis of the content of \verb|/etc/apache2/mods-enabled| suggests
that the following packages are needed:

@d restore instructions @{@%
apt-get install libapache2-mod-auth-plain libapache2-mod-fcgid
apt-get install libapache2-mod-fcgid libapache2-mod-passenger libapache2-mod-php5
@| @}


We need to supply secret stuff, e.g. passwords. Do this in a file that
is not shared in Github. What follows is a template.



@d ``run'' commands in Dockerfile  @{@%
@% RUN /root/restore
@| @}



\section{Connect to the back-up of the original source}
\label{sec:restore}

@% A recent back-up of parts of the image of the website-server can be
@% found in a server called \texttt{paulhuygen.hopto.org/}. We can
@% connect to it using a private key that has been stored in the
@% transfer-directory.
@% 
@% @d restore instructions @{@%
@% mkdir -p m4_local_b2l_repo
@% sshfs -o ssh_command="ssh -i /root/transferdir/rokey" m4_backup_user@@m4_backup_host:m4_remote_location m4_backup_mountpoint 
@% @| sshfs @}
@% 
@% Mount the directory of the back-up on directory \texttt{/backup}. We
@% assume that the back-up files that backup2l has made are available on
@% directory \texttt{m4_host_b2l_repo} on the Docker host. The
@% \texttt{docker run} instruction contains a mount option that connects
@% this directory to the local \verb|/backup| directory.
@% 
@% The program backup2l needs a configuration-file that tells it where
@% the back-up is located. Generate such a config-file. To be safe I filled in all the variables from
@% the original config-file, although most of them are probably not needed.
@% 
@% @o <!!>m4_bak_config_file<!!> @{@%
@% FOR_VERSION=1.5
@% VOLNAME="all"
@% SRCLIST=(/etc /root /home /var/mail /usr/local /srv)
@% SKIPCOND=(-false)
@% BACKUP_DIR="<!!>m4_local_b2l_repo<!!>"
@% MAX_LEVEL=3
@% MAX_PER_LEVEL=8
@% MAX_FULL=2
@% GENERATIONS=1
@% CREATE_CHECK_FILE=1
@% PRE_BACKUP ()
@% {  # Nothing to do
@% }
@% 
@% # This user-defined bash function is executed after a backup is made
@% POST_BACKUP ()
@% {
@%   # Nothing to do
@% }
@% AUTORUN=0
@% SIZE_UNITS="G"
@% @| @}
@% 
@% @d copy stuff to the image @{@%
@% COPY m4_bak_config_file /root/
@% @| @}

When we run the Docker image, we mount an image of the original disk
on directory \verb|/backup| (see section~\ref{sec:run-the-image}).

\section{Install the software}
\label{sec:install_all}

Install the software to run the  \href{cltl.nl}{cltl} website.  As far
as I am aware now, the wbsite needs 1) Wordpress; 2) Mysql database
and 3) Apache. Much of the software can be obtained from the Ubuntu
repository. So, update \verb|apt| to enable it to install packages.

We can not perform the installation automatically yet. Too much
elements require manual intervention, e.g. to fill in passwords.

@d ``run'' commands in Dockerfile  @{@%
@% RUN /root/restore
@| @}



\subsection{Install the Mysql database}
\label{sec:install_mysql}

Install the Debian packages for Mysql and load it with the database
that has been back-upped from the original source. Unfortunately I do
not yet know how to install the packages without the need for
intervention by a human operator. You have to provide a root
password. Please note this password in a safe place.

Install and start mysql:

@d restore instructions @{@%
apt-get install mysql-common mysql-client mysql-server
service mysql start
@| @}

Install the back-up of the Mysql database. This back-up is in a file
\verb|<!!>m4_db_dumpfile<!!>| that has been generated by mysqldump. It should be
located in a ``sister''  directory \verb|wpbak|. 
\begin{enumerate}
\item Put this back-up file in the transfer directory to have it
  imported into the image.
\item Generate the Wordpress user in Mysql.
\item Restore the database in Mysql.
\end{enumerate}

Put the back-up file into the transfer directory. If it cannot be
found, stop further actions.

@d preliminary checks @{@%
if
  [ ! -e "transferdir/<!!>m4_db_dumpfile<!!>" ]
then
  cp ../wpbak/<!!>m4_db_dumpfile transferdir/ 2>/dev/null
  if
    [ $? .gt. 0 ]
  then
    echo "Mysql dumpfile m4_db_dumpfile not present"
    exit 1 
  fi
fi
@| @}

Generate the Wordpress user with a password. During the installation
you had to fill in a main Mysql password by hand. Hopefully you still
remember this password now. Hopefully the password of the
Wordpress-user has been written in the 
secret file. 


@d password stuff @{@%
MYSQL_ROOT_PASSWORD="root_password"
WP_MYSQL_PASSWORD="mysql_password"
@| @}

If all is OK, we are ready to generate the Wordpress user and allow it
to handle the Wordpress database.

@d restore instructions @{@%
echo
echo Generate the Wordpress database user and grant privileges.
echo
MYSQL_ROOT_USER="root"
MYSQL_WP_USERNAME="wordpress_usr"
DATABASE_NAME="wordpress_db"
mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE USER '$MYSQL_WP_USERNAME'@@'localhost' IDENTIFIED BY '$WP_MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$MYSQL_WP_USERNAME'@@'localhost';
FLUSH PRIVILEGES;
EOF
@| MYSQL_WP_USERNAME DATABASE_NAME MYSQL_ROOT_USER @}

Next, create the database as Wordpress-user and restore it from the backup.


@d restore instructions @{@%
echo
echo Restore $DATABASE_NAME from the back-up
echo
mysql -u $MYSQL_WP_USERNAME -p$WP_MYSQL_PASSWORD -e "create database $DATABASE_NAME"
mysql -u $MYSQL_WP_USERNAME -p$WP_MYSQL_PASSWORD $DATABASE_NAME < transferdir/<!!>m4_db_dumpfile
@| @}

\subsection{Restore Apache}
\label{sec:apache}

To restore apache, we will install the Ubunto Apache package and then restore the Apache config files in \texttt{/etc}.

@d restore instructions @{@%
apt-get install apache2
  
@| @}



\subsection{restore files from the backup2l repo}
\label{sec:restore_from_backup2l}

To access the b2l repo backup2l needs a configuration file. 


\section{Run the Docker image}
\label{sec:run-the-image}

@o run_the_image @{@%
#!/bin/bash
# run_the_image -- start a container with the cltl image
docker run   -it --mount
type=bind,src=<!!>m4_host_b2l_repo<!!>,target=<!!>m4_local_b2l_repo<!!> --expose 80 m4_docker_image
@| @}

@d make scripts executable @{@%
chmod 775 run_the_image
@| @}

Make sure that the mount-point in the docker image exists.

@d restore instructions @{@%
mkdir -p m4_local_b2l_repo
@| @}



\section{Indexes}
\label{sec:indexes}

\subsection{Filenames}
\label{sec:filenames}

@f

\subsection{Macro's}
\label{sec:macros}

@m

\subsection{Variables}
\label{sec:veriables}

@u

@% \subsection{General index}
@% \label{sec:genindex}

\printindex

\end{document}
