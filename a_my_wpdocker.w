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
@< ``run'' commands in Dockerfile @>
CMD ["/bin/bash"]
@| @}

@o doit @{@%
  make sources
  @< build the Docker image @>
@| @}


@d build the Docker image @{@%
docker build -t ubuntu-docker .
@| @}

\section{Connect to the back-up of the original source}
\label{sec:restore}

We used \href{https://github.com/gkiefer/backup2l}{backup2l} to
back-up the server, so we need this program in our image te restore
things:

@d ``run'' commands in Dockerfile @{@%
RUN apt-get update
RUN apt-get install backup2l
@| backup2l @}


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
