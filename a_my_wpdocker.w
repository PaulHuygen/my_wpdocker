m4_include(inst.m4)m4_dnl
\documentclass[twoside]{artikel3}
\newcommand{\theTitle}{m4_doctitle}
\newcommand{\theAuthor}{m4_author}
\input{thelatexheader.tex}
\begin{document}
\maketitle

\begin{abstract}
This document generates a Docker image that contains te Wordpress
website of CLTL.nl. It is derived from a back-up fom the actual
website.   

\end{abstract}

\section{Introduction}
\label{sec:introduction}

This document constructs a restauration of a Wordpress website from a
back-up. A Docker image with the restauration of the site is made. It
serves the following purposes:

\begin{enumerate}
 \item Provide proof that the back-up is complete. In other words, it is
   guaranteed that, if a disaster happens, the website can be
   restored.
 \item Describe how it works. After a while, the knowledge on how to
   use the software instruments for the restauration becomes
   rusty. Hopefully this document provides clear instructions.
 \item The software on the original site has not been updated for a
   long time. When a Docker with a duplicate exists, this can serve as
   a template to test upgrading.
\end{enumerate}

\subsection{Tasks to be performed}
\label{sec:tasks}

First We have to do the following:

\begin{enumerate}
\item Construct a Docker image with the correct version of the
  operating system on it. The original server uses a very old version
  of Ubuntu linux: \texttt{m4_long_ubuntuversion}.
\item Restore the accounts of the users that where known in the
  original server.
\item Install the database and restore the WordPress part on it.
\item Install the Apache web-server.
\item Restore the WordPress site. This is of a very old version too.
\item Test whether it works.
\end{enumerate}

When this works, we will bother about upgrading the operating system
and the Wordpress version to the latest.

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

@o doit @{@%
#!/bin/bash
# doit -- generate the image
@< init doit @>
make sources
@< build the Docker image @>
@< make scripts executable @>

# @< finit doit @>
@| @}


@d build the Docker image @{@%
docker build -t m4_docker_image .
@| @}

To restore the Wordpress-site on the image, \texttt{RUN} a script with
instructions.

@o restore @{@%
#!/bin/bash
@< restore instructions @>
@| @}

@d make scripts executable @{@%
chmod 775 restore
@| @}


@d copy stuff to the image @{@%
COPY --chmod=755 restore /root/restore
@| @}

@d ``run'' commands in Dockerfile  @{@%
RUN /root/restore
@| @}



\section{Connect to the back-up of the original source}
\label{sec:restore}

We used \href{https://github.com/gkiefer/backup2l}{backup2l} to
back-up the server, so we need this program in our image te restore
things:

@d restore instructions @{@%
apt-get update
apt-get install backup2l
@| backup2l @}

Mount the directory of the back-up on directory \texttt{/backup}. We
assume that the back-up files that backup2l has made are available on
directory \texttt{m4_host_b2l_repo} on the Docker host. The
\texttt{docker run} instruction contains a mount option that connects
this directory to the local \verb|/backup| directory.

@d init doit @{@%
source  m4_local_initscript
@| @}


\section{Run the Docker image}
\label{sec:run-the-image}

@o run_the_image @{@%
#!/bin/bash
# run_the_image -- start a container with the cltl image
docker run   -it --mount type=bind,src=<!!>m4_host_b2l_repo<!!>,target=<!!>m4_local_b2l_repo<!!>  m4_docker_image
@| @}

@d make macros executable @{@%
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
