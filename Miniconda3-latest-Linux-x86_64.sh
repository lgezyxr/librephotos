#!/bin/sh
#
# NAME:  Miniconda3
# VER:   py38_4.9.2
# PLAT:  linux-64
# LINES: 578
# MD5:   d84cff5da9dc8f4cd1a947cd13521f66

export OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
unset LD_LIBRARY_PATH
if ! echo "$0" | grep '\.sh$' > /dev/null; then
    printf 'Please run using "bash" or "sh", but not "." or "source"\\n' >&2
    return 1
fi

# Determine RUNNING_SHELL; if SHELL is non-zero use that.
if [ -n "$SHELL" ]; then
    RUNNING_SHELL="$SHELL"
else
    if [ "$(uname)" = "Darwin" ]; then
        RUNNING_SHELL=/bin/bash
    else
        if [ -d /proc ] && [ -r /proc ] && [ -d /proc/$$ ] && [ -r /proc/$$ ] && [ -L /proc/$$/exe ] && [ -r /proc/$$/exe ]; then
            RUNNING_SHELL=$(readlink /proc/$$/exe)
        fi
        if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
            RUNNING_SHELL=$(ps -p $$ -o args= | sed 's|^-||')
            case "$RUNNING_SHELL" in
                */*)
                    ;;
                default)
                    RUNNING_SHELL=$(which "$RUNNING_SHELL")
                    ;;
            esac
        fi
    fi
fi

# Some final fallback locations
if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
    if [ -f /bin/bash ]; then
        RUNNING_SHELL=/bin/bash
    else
        if [ -f /bin/sh ]; then
            RUNNING_SHELL=/bin/sh
        fi
    fi
fi

if [ -z "$RUNNING_SHELL" ] || [ ! -f "$RUNNING_SHELL" ]; then
    printf 'Unable to determine your shell. Please set the SHELL env. var and re-run\\n' >&2
    exit 1
fi

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
THIS_FILE=$(basename "$0")
THIS_PATH="$THIS_DIR/$THIS_FILE"
PREFIX=$HOME/miniconda3
BATCH=0
FORCE=0
SKIP_SCRIPTS=0
TEST=0
REINSTALL=0
USAGE="
usage: $0 [options]

Installs Miniconda3 py38_4.9.2

-b           run install in batch mode (without manual intervention),
             it is expected the license terms are agreed upon
-f           no error if install prefix already exists
-h           print this help message and exit
-p PREFIX    install prefix, defaults to $PREFIX, must not contain spaces.
-s           skip running pre/post-link/install scripts
-u           update an existing installation
-t           run package tests after installation (may install conda-build)
"

if which getopt > /dev/null 2>&1; then
    OPTS=$(getopt bfhp:sut "$*" 2>/dev/null)
    if [ ! $? ]; then
        printf "%s\\n" "$USAGE"
        exit 2
    fi

    eval set -- "$OPTS"

    while true; do
        case "$1" in
            -h)
                printf "%s\\n" "$USAGE"
                exit 2
                ;;
            -b)
                BATCH=1
                shift
                ;;
            -f)
                FORCE=1
                shift
                ;;
            -p)
                PREFIX="$2"
                shift
                shift
                ;;
            -s)
                SKIP_SCRIPTS=1
                shift
                ;;
            -u)
                FORCE=1
                shift
                ;;
            -t)
                TEST=1
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$1"
                exit 1
                ;;
        esac
    done
else
    while getopts "bfhp:sut" x; do
        case "$x" in
            h)
                printf "%s\\n" "$USAGE"
                exit 2
            ;;
            b)
                BATCH=1
                ;;
            f)
                FORCE=1
                ;;
            p)
                PREFIX="$OPTARG"
                ;;
            s)
                SKIP_SCRIPTS=1
                ;;
            u)
                FORCE=1
                ;;
            t)
                TEST=1
                ;;
            ?)
                printf "ERROR: did not recognize option '%s', please try -h\\n" "$x"
                exit 1
                ;;
        esac
    done
fi

if [ "$BATCH" = "0" ] # interactive mode
then
    if [ "$(uname -m)" != "x86_64" ]; then
        printf "WARNING:\\n"
        printf "    Your operating system appears not to be 64-bit, but you are trying to\\n"
        printf "    install a 64-bit version of Miniconda3.\\n"
        printf "    Are sure you want to continue the installation? [yes|no]\\n"
        printf "[no] >>> "
        read -r ans
        if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
           [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
        then
            printf "Aborting installation\\n"
            exit 2
        fi
    fi
    if [ "$(uname)" != "Linux" ]; then
        printf "WARNING:\\n"
        printf "    Your operating system does not appear to be Linux, \\n"
        printf "    but you are trying to install a Linux version of Miniconda3.\\n"
        printf "    Are sure you want to continue the installation? [yes|no]\\n"
        printf "[no] >>> "
        read -r ans
        if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
           [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
        then
            printf "Aborting installation\\n"
            exit 2
        fi
    fi
    printf "\\n"
    printf "Welcome to Miniconda3 py38_4.9.2\\n"
    printf "\\n"
    printf "In order to continue the installation process, please review the license\\n"
    printf "agreement.\\n"
    printf "Please, press ENTER to continue\\n"
    printf ">>> "
    read -r dummy
    pager="cat"
    if command -v "more" > /dev/null 2>&1; then
      pager="more"
    fi
    "$pager" <<EOF
===================================
End User License Agreement - Anaconda Individual Edition
===================================

Copyright 2015-2020, Anaconda, Inc.

All rights reserved under the 3-clause BSD License:

This End User License Agreement (the "Agreement") is a legal agreement between you and Anaconda, Inc. ("Anaconda") and governs your use of Anaconda Individual Edition (which was formerly known as Anaconda Distribution).

Subject to the terms of this Agreement, Anaconda hereby grants you a non-exclusive, non-transferable license to:

  * Install and use the Anaconda Individual Edition (which was formerly known as Anaconda Distribution),
  * Modify and create derivative works of sample source code delivered in Anaconda Individual Edition from Anaconda's repository; and
  * Redistribute code files in source (if provided to you by Anaconda as source) and binary forms, with or without modification subject to the requirements set forth below.

Anaconda may, at its option, make available patches, workarounds or other updates to Anaconda Individual Edition. Unless the updates are provided with their separate governing terms, they are deemed part of Anaconda Individual Edition licensed to you as provided in this Agreement.  This Agreement does not entitle you to any support for Anaconda Individual Edition.

Anaconda reserves all rights not expressly granted to you in this Agreement.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of Anaconda nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

You acknowledge that, as between you and Anaconda, Anaconda owns all right, title, and interest, including all intellectual property rights, in and to Anaconda Individual Edition and, with respect to third-party products distributed with or through Anaconda Individual Edition, the applicable third-party licensors own all right, title and interest, including all intellectual property rights, in and to such products.  If you send or transmit any communications or materials to Anaconda suggesting or recommending changes to the software or documentation, including without limitation, new features or functionality relating thereto, or any comments, questions, suggestions or the like ("Feedback"), Anaconda is free to use such Feedback. You hereby assign to Anaconda all right, title, and interest in, and Anaconda is free to use, without any attribution or compensation to any party, any ideas, know-how, concepts, techniques or other intellectual property rights contained in the Feedback, for any purpose whatsoever, although Anaconda is not required to use any Feedback.

THIS SOFTWARE IS PROVIDED BY ANACONDA AND ITS CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ANACONDA BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

TO THE MAXIMUM EXTENT PERMITTED BY LAW, ANACONDA AND ITS AFFILIATES SHALL NOT BE LIABLE FOR ANY SPECIAL, INCIDENTAL, PUNITIVE OR CONSEQUENTIAL DAMAGES, OR ANY LOST PROFITS, LOSS OF USE, LOSS OF DATA OR LOSS OF GOODWILL, OR THE COSTS OF PROCURING SUBSTITUTE PRODUCTS, ARISING OUT OF OR IN CONNECTION WITH THIS AGREEMENT OR THE USE OR PERFORMANCE OF ANACONDA INDIVIDUAL EDITION, WHETHER SUCH LIABILITY ARISES FROM ANY CLAIM BASED UPON BREACH OF CONTRACT, BREACH OF WARRANTY, TORT (INCLUDING NEGLIGENCE), PRODUCT LIABILITY OR ANY OTHER CAUSE OF ACTION OR THEORY OF LIABILITY. IN NO EVENT WILL THE TOTAL CUMULATIVE LIABILITY OF ANACONDA AND ITS AFFILIATES UNDER OR ARISING OUT OF THIS AGREEMENT EXCEED US$10.00.

If you want to terminate this Agreement, you may do so by discontinuing use of Anaconda Individual Edition.  Anaconda may, at any time, terminate this Agreement and the license granted hereunder if you fail to comply with any term of this Agreement.   Upon any termination of this Agreement, you agree to promptly discontinue use of the Anaconda Individual Edition and destroy all copies in your possession or control. Upon any termination of this Agreement all provisions survive except for the licenses granted to you.

This Agreement is governed by and construed in accordance with the internal laws of the State of Texas without giving effect to any choice or conflict of law provision or rule that would require or permit the application of the laws of any jurisdiction other than those of the State of Texas. Any legal suit, action, or proceeding arising out of or related to this Agreement or the licenses granted hereunder by you must be instituted exclusively in the federal courts of the United States or the courts of the State of Texas in each case located in Travis County, Texas, and you irrevocably submit to the jurisdiction of such courts in any such suit, action, or proceeding.


Notice of Third Party Software Licenses
=======================================

Anaconda Individual Edition provides access to a repository which contains software packages or tools licensed on an open source basis from third parties and binary packages of these third party tools. These third party software packages or tools are provided on an "as is" basis and are subject to their respective license agreements as well as this Agreement and the Terms of Service for the Repository located at https://know.anaconda.com/TOS.html; provided, however, no restriction contained in the Terms of Service shall be construed so as to limit your ability to download the packages contained in Anaconda Individual Edition provided you comply with the license for each such package.  These licenses may be accessed from within the Anaconda Individual Edition software or at https://docs.anaconda.com/anaconda/pkg-docs. Information regarding which license is applicable is available from within many of the third party software packages and tools and at https://repo.anaconda.com/pkgs/main/ and https://repo.anaconda.com/pkgs/r/. Anaconda reserves the right, in its sole discretion, to change which third party tools are included in the repository accessible through Anaconda Individual Edition.

Intel Math Kernel Library
-------------------------

Anaconda Individual Edition provides access to re-distributable, run-time, shared-library files from the Intel Math Kernel Library ("MKL binaries").

Copyright 2018 Intel Corporation.  License available at https://software.intel.com/en-us/license/intel-simplified-software-license (the "MKL License").

You may use and redistribute the MKL binaries, without modification, provided the following conditions are met:

  * Redistributions must reproduce the above copyright notice and the following terms of use in the MKL binaries and in the documentation and/or other materials provided with the distribution.
  * Neither the name of Intel nor the names of its suppliers may be used to endorse or promote products derived from the MKL binaries without specific prior written permission.
  * No reverse engineering, decompilation, or disassembly of the MKL binaries is permitted.

You are specifically authorized to use and redistribute the MKL binaries with your installation of Anaconda Individual Edition subject to the terms set forth in the MKL License. You are also authorized to redistribute the MKL binaries with Anaconda Individual Edition or in the Anaconda package that contains the MKL binaries. If needed, instructions for removing the MKL binaries after installation of Anaconda Individual Edition are available at https://docs.anaconda.com.

cuDNN Software
--------------

Anaconda Individual Edition also provides access to cuDNN software binaries ("cuDNN binaries") from NVIDIA Corporation. You are specifically authorized to use the cuDNN binaries with your installation of Anaconda Individual Edition subject to your compliance with the license agreement located at https://docs.nvidia.com/deeplearning/sdk/cudnn-sla/index.html. You are also authorized to redistribute the cuDNN binaries with an Anaconda Individual Edition package that contains the cuDNN binaries. You can add or remove the cuDNN binaries utilizing the install and uninstall features in Anaconda Individual Edition.

cuDNN binaries contain source code provided by NVIDIA Corporation.


Export; Cryptography Notice
===========================

You must comply with all domestic and international export laws and regulations that apply to the software, which include restrictions on destinations, end users, and end use.  Anaconda Individual Edition includes cryptographic software. The country in which you currently reside may have restrictions on the import, possession, use, and/or re-export to another country, of encryption software. BEFORE using any encryption software, please check your country's laws, regulations and policies concerning the import, possession, or use, and re-export of encryption software, to see if this is permitted. See the Wassenaar Arrangement http://www.wassenaar.org/ for more information.

Anaconda has self-classified this software as Export Commodity Control Number (ECCN) 5D992.c, which includes mass market information security software using or performing cryptographic functions with asymmetric algorithms. No license is required for export of this software to non-embargoed countries.

The Intel Math Kernel Library contained in Anaconda Individual Edition is classified by Intel as ECCN 5D992.c with no license required for export to non-embargoed countries.

The following packages are included in the repository accessible through Anaconda Individual Edition that relate to cryptography:

openssl
    The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open Source toolkit implementing the Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols as well as a full-strength general purpose cryptography library.

pycrypto
    A collection of both secure hash functions (such as SHA256 and RIPEMD160), and various encryption algorithms (AES, DES, RSA, ElGamal, etc.).

pyopenssl
    A thin Python wrapper around (a subset of) the OpenSSL library.

kerberos (krb5, non-Windows platforms)
    A network authentication protocol designed to provide strong authentication for client/server applications by using secret-key cryptography.

cryptography
    A Python library which exposes cryptographic recipes and primitives.

pycryptodome
    A fork of PyCrypto. It is a self-contained Python package of low-level cryptographic primitives.

pycryptodomex
    A stand-alone version of pycryptodome.

libsodium
    A software library for encryption, decryption, signatures, password hashing and more.

pynacl
    A Python binding to the Networking and Cryptography library, a crypto library with the stated goal of improving usability, security and speed.


Last updated September 28, 2020

EOF
    printf "\\n"
    printf "Do you accept the license terms? [yes|no]\\n"
    printf "[no] >>> "
    read -r ans
    while [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
          [ "$ans" != "no" ]  && [ "$ans" != "No" ]  && [ "$ans" != "NO" ]
    do
        printf "Please answer 'yes' or 'no':'\\n"
        printf ">>> "
        read -r ans
    done
    if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ]
    then
        printf "The license agreement wasn't approved, aborting installation.\\n"
        exit 2
    fi
    printf "\\n"
    printf "Miniconda3 will now be installed into this location:\\n"
    printf "%s\\n" "$PREFIX"
    printf "\\n"
    printf "  - Press ENTER to confirm the location\\n"
    printf "  - Press CTRL-C to abort the installation\\n"
    printf "  - Or specify a different location below\\n"
    printf "\\n"
    printf "[%s] >>> " "$PREFIX"
    read -r user_prefix
    if [ "$user_prefix" != "" ]; then
        case "$user_prefix" in
            *\ * )
                printf "ERROR: Cannot install into directories with spaces\\n" >&2
                exit 1
                ;;
            *)
                eval PREFIX="$user_prefix"
                ;;
        esac
    fi
fi # !BATCH

case "$PREFIX" in
    *\ * )
        printf "ERROR: Cannot install into directories with spaces\\n" >&2
        exit 1
        ;;
esac

if [ "$FORCE" = "0" ] && [ -e "$PREFIX" ]; then
    printf "ERROR: File or directory already exists: '%s'\\n" "$PREFIX" >&2
    printf "If you want to update an existing installation, use the -u option.\\n" >&2
    exit 1
elif [ "$FORCE" = "1" ] && [ -e "$PREFIX" ]; then
    REINSTALL=1
fi


if ! mkdir -p "$PREFIX"; then
    printf "ERROR: Could not create directory: '%s'\\n" "$PREFIX" >&2
    exit 1
fi

PREFIX=$(cd "$PREFIX"; pwd)
export PREFIX

printf "PREFIX=%s\\n" "$PREFIX"

# verify the MD5 sum of the tarball appended to this header
MD5=$(tail -n +578 "$THIS_PATH" | md5sum -)
if ! echo "$MD5" | grep d84cff5da9dc8f4cd1a947cd13521f66 >/dev/null; then
    printf "WARNING: md5sum mismatch of tar archive\\n" >&2
    printf "expected: d84cff5da9dc8f4cd1a947cd13521f66\\n" >&2
    printf "     got: %s\\n" "$MD5" >&2
fi

# extract the tarball appended to this header, this creates the *.tar.bz2 files
# for all the packages which get installed below
cd "$PREFIX"

# disable sysconfigdata overrides, since we want whatever was frozen to be used
unset PYTHON_SYSCONFIGDATA_NAME _CONDA_PYTHON_SYSCONFIGDATA_NAME

CONDA_EXEC="$PREFIX/conda.exe"
# 3-part dd from https://unix.stackexchange.com/a/121798/34459
# this is similar below with the tarball payload - see shar.py in constructor to see how
#    these values are computed.
{
    dd if="$THIS_PATH" bs=1 skip=27292                  count=5476                      2>/dev/null
    dd if="$THIS_PATH" bs=16384        skip=2                      count=928                   2>/dev/null
    dd if="$THIS_PATH" bs=1 skip=15237120                   count=5380                    2>/dev/null
} > "$CONDA_EXEC"

chmod +x "$CONDA_EXEC"

export TMP_BACKUP="$TMP"
export TMP=$PREFIX/install_tmp

printf "Unpacking payload ...\n"
{
    dd if="$THIS_PATH" bs=1 skip=15242500               count=11004                     2>/dev/null
    dd if="$THIS_PATH" bs=16384        skip=931                    count=4820                  2>/dev/null
    dd if="$THIS_PATH" bs=1 skip=94224384                   count=11538                   2>/dev/null
} | "$CONDA_EXEC" constructor --extract-tar --prefix "$PREFIX"

"$CONDA_EXEC" constructor --prefix "$PREFIX" --extract-conda-pkgs || exit 1

PRECONDA="$PREFIX/preconda.tar.bz2"
"$CONDA_EXEC" constructor --prefix "$PREFIX" --extract-tarball < "$PRECONDA" || exit 1
rm -f "$PRECONDA"

PYTHON="$PREFIX/bin/python"
MSGS="$PREFIX/.messages.txt"
touch "$MSGS"
export FORCE

# original issue report:
# https://github.com/ContinuumIO/anaconda-issues/issues/11148
# First try to fix it (this apparently didn't work; QA reported the issue again)
# https://github.com/conda/conda/pull/9073
mkdir -p ~/.conda > /dev/null 2>&1

CONDA_SAFETY_CHECKS=disabled \
CONDA_EXTRA_SAFETY_CHECKS=no \
CONDA_ROLLBACK_ENABLED=no \
CONDA_CHANNELS=https://repo.anaconda.com/pkgs/main,https://repo.anaconda.com/pkgs/main,https://repo.anaconda.com/pkgs/r,https://repo.anaconda.com/pkgs/pro \
CONDA_PKGS_DIRS="$PREFIX/pkgs" \
"$CONDA_EXEC" install --offline --file "$PREFIX/pkgs/env.txt" -yp "$PREFIX" || exit 1



POSTCONDA="$PREFIX/postconda.tar.bz2"
"$CONDA_EXEC" constructor --prefix "$PREFIX" --extract-tarball < "$POSTCONDA" || exit 1
rm -f "$POSTCONDA"

rm -f $PREFIX/conda.exe
rm -f $PREFIX/pkgs/env.txt

rm -rf $PREFIX/install_tmp
export TMP="$TMP_BACKUP"

mkdir -p $PREFIX/envs

if [ -f "$MSGS" ]; then
  cat "$MSGS"
fi
rm -f "$MSGS"
# handle .aic files
$PREFIX/bin/python -E -s "$PREFIX/pkgs/.cio-config.py" "$THIS_PATH" || exit 1
printf "installation finished.\\n"

if [ "$PYTHONPATH" != "" ]; then
    printf "WARNING:\\n"
    printf "    You currently have a PYTHONPATH environment variable set. This may cause\\n"
    printf "    unexpected behavior when running the Python interpreter in Miniconda3.\\n"
    printf "    For best results, please verify that your PYTHONPATH only points to\\n"
    printf "    directories of packages that are compatible with the Python interpreter\\n"
    printf "    in Miniconda3: $PREFIX\\n"
fi

if [ "$BATCH" = "0" ]; then
    # Interactive mode.
    BASH_RC="$HOME"/.bashrc
    DEFAULT=no
    printf "Do you wish the installer to initialize Miniconda3\\n"
    printf "by running conda init? [yes|no]\\n"
    printf "[%s] >>> " "$DEFAULT"
    read -r ans
    if [ "$ans" = "" ]; then
        ans=$DEFAULT
    fi
    if [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
       [ "$ans" != "y" ]   && [ "$ans" != "Y" ]
    then
        printf "\\n"
        printf "You have chosen to not have conda modify your shell scripts at all.\\n"
        printf "To activate conda's base environment in your current shell session:\\n"
        printf "\\n"
        printf "eval \"\$($PREFIX/bin/conda shell.YOUR_SHELL_NAME hook)\" \\n"
        printf "\\n"
        printf "To install conda's shell functions for easier access, first activate, then:\\n"
        printf "\\n"
        printf "conda init\\n"
        printf "\\n"
    else
        if [[ $SHELL = *zsh ]]
        then
            $PREFIX/bin/conda init zsh
        else
            $PREFIX/bin/conda init
        fi
    fi
    printf "If you'd prefer that conda's base environment not be activated on startup, \\n"
    printf "   set the auto_activate_base parameter to false: \\n"
    printf "\\n"
    printf "conda config --set auto_activate_base false\\n"
    printf "\\n"

    printf "Thank you for installing Miniconda3!\\n"
fi # !BATCH

if [ "$TEST" = "1" ]; then
    printf "INFO: Running package tests in a subshell\\n"
    (. "$PREFIX"/bin/activate
     which conda-build > /dev/null 2>&1 || conda install -y conda-build
     if [ ! -d "$PREFIX"/conda-bld/linux-64 ]; then
         mkdir -p "$PREFIX"/conda-bld/linux-64
     fi
     cp -f "$PREFIX"/pkgs/*.tar.bz2 "$PREFIX"/conda-bld/linux-64/
     cp -f "$PREFIX"/pkgs/*.conda "$PREFIX"/conda-bld/linux-64/
     conda index "$PREFIX"/conda-bld/linux-64/
     conda-build --override-channels --channel local --test --keep-going "$PREFIX"/conda-bld/linux-64/*.tar.bz2
    )
    NFAILS=$?
    if [ "$NFAILS" != "0" ]; then
        if [ "$NFAILS" = "1" ]; then
            printf "ERROR: 1 test failed\\n" >&2
            printf "To re-run the tests for the above failed package, please enter:\\n"
            printf ". %s/bin/activate\\n" "$PREFIX"
            printf "conda-build --override-channels --channel local --test <full-path-to-failed.tar.bz2>\\n"
        else
            printf "ERROR: %s test failed\\n" $NFAILS >&2
            printf "To re-run the tests for the above failed packages, please enter:\\n"
            printf ". %s/bin/activate\\n" "$PREFIX"
            printf "conda-build --override-channels --channel local --test <full-path-to-failed.tar.bz2>\\n"
        fi
        exit $NFAILS
    fi
fi

if [ "$BATCH" = "0" ]; then
    if [ -f "$PREFIX/pkgs/vscode_inst.py" ]; then
      $PYTHON -E -s "$PREFIX/pkgs/vscode_inst.py" --is-supported
      if [ "$?" = "0" ]; then
          printf "\\n"
          printf "===========================================================================\\n"
          printf "\\n"
          printf "Anaconda is partnered with Microsoft! Microsoft VSCode is a streamlined\\n"
          printf "code editor with support for development operations like debugging, task\\n"
          printf "running and version control.\\n"
          printf "\\n"
          printf "To install Visual Studio Code, you will need:\\n"
          if [ "$(uname)" = "Linux" ]; then
              printf -- "  - Administrator Privileges\\n"
          fi
          printf -- "  - Internet connectivity\\n"
          printf "\\n"
          printf "Visual Studio Code License: https://code.visualstudio.com/license\\n"
          printf "\\n"
          printf "Do you wish to proceed with the installation of Microsoft VSCode? [yes|no]\\n"
          printf ">>> "
          read -r ans
          while [ "$ans" != "yes" ] && [ "$ans" != "Yes" ] && [ "$ans" != "YES" ] && \
                [ "$ans" != "no" ]  && [ "$ans" != "No" ]  && [ "$ans" != "NO" ]
          do
              printf "Please answer 'yes' or 'no':\\n"
              printf ">>> "
              read -r ans
          done
          if [ "$ans" = "yes" ] || [ "$ans" = "Yes" ] || [ "$ans" = "YES" ]
          then
              printf "Proceeding with installation of Microsoft VSCode\\n"
              $PYTHON -E -s "$PREFIX/pkgs/vscode_inst.py" --handle-all-steps || exit 1
          fi
      fi
    fi
fi
exit 0
@@END_HEADER@@
ELF          >    V       @       (#�         @ 8  @         @       @       @       h      h                   �      �      �                                                         �      �                                           F?      F?                    `       `       `      (      (                    �       �       �      �      H                  ��      ��      ��      �      �                   �      �      �                             P�td   ,q      ,q      ,q      ,      ,             Q�td                                                  R�td    �       �       �      �      �             /lib64/ld-linux-x86-64.so.2          GNU                   �   P   >   8                   9   =                  F               *   K                 .                           "       3   M                     )      #       4   &   1       (   :      ,       '   G       ?       E                       H                             N           B              5       /   O       <   2                                                 L               $   I                   -         C          
                                                                      	               7                            ;           6               0                  O           �     O       �e�m                            �                                          &                     �                     �                     �                     H                     !                     �                                             �                     �                      �                      O                     �                     o                     U                     )                     �                     [                     �                                          �                     �                     z                     7                     �                     }                     �                     �                     �                     J                     R                                          �                      �                     �                      s                     �                                                               n                     (                       �                     }                      b                     �                      a                     �                      �                     �                      W                      �                     �                                           �                     �                     �                     �                     �                      �                      �                      p                      u                     �                                           g                     �                     C                     �                     h                     �                     5                     7                       Q                      2                     ^                                           �  "                    libdl.so.2 _ITM_deregisterTMCloneTable __gmon_start__ _ITM_registerTMCloneTable dlsym dlopen dlerror libz.so.1 inflateInit_ inflateEnd inflate libc.so.6 __stpcpy_chk __xpg_basename mkdtemp fflush strcpy fchmod readdir setlocale fopen wcsncpy strncmp __strdup perror closedir ftell signal strncpy mbstowcs fork __stack_chk_fail unlink mkdir stdin getpid kill strtok feof calloc strlen memset dirname rmdir fseek clearerr unsetenv __fprintf_chk stdout strnlen fclose __vsnprintf_chk malloc strcat raise __strncpy_chk nl_langinfo opendir getenv stderr __snprintf_chk __strncat_chk execvp strncat __realpath_chk fileno fwrite fread waitpid strchr __vfprintf_chk __strcpy_chk __cxa_finalize __xstat __strcat_chk setbuf strcmp __libc_start_main ferror stpcpy free GLIBC_2.2.5 GLIBC_2.4 GLIBC_2.3.4 $ORIGIN/../../../../.. XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                          ui	   �        �          ii
           ��                    �                    �         
  H��I��L��I��$x  L�
L���D  �   H��L���oa  ��$�   tۉ����a   �����f.�     H����a  � .pkg�@ H����    U��H�5�&  SH��H��� c  H��d  H�H����  H�5�&  H����b  H��d  H�H����  H�5�&  H����b  H��d  H�H����  H�5�&  H����b  H�Xd  H�H����  H�5�&  H����b  H�-d  H�H����  H�5�&  H���qb  H�d  H�H����  H�5�&  H���Nb  H��c  H�H����  H�5�&  H���+b  H��c  H�H����  H�5~&  H���b  H��c  H�H���u  H�5i&  H����a  H�Vc  H�H���i  H�5l&  H����a  H�+c  H�H���]  H�5s&  H����a  H� c  H�H���Q  H�5v&  H���|a  H��b  H�H���(  ���H  H�5�&  H���Pa  H��b  H�H���  H�5�&  H���-a  H�fb  H�H���
a  H�;b  H�H���  H�5w&  H����`  H�b  H�H���  H�5~&  H����`  H��a  H�H����  H�5j&  H����`  H��a  H�H����  H�5q&  H���~`  H��a  H�H����  H�5a&  H���[`  H�da  H�H����  H�5V&  H���8`  H�9a  H�H����  H�5I&  H���`  H�a  H�H����  H�54&  H����_  H��`  H�H����  H�59&  H����_  H��`  H�H����  H�5$&  H����_  H��`  H�H���r  H�5&  H����_  H�b`  H�H����  H�5&  H���f_  H�7`  H�H���Z  H�5�%  H���C_  H�`  H�H���  ���o  H�5&  H���_  H��_  H�H���P  H�5�%  H����^  H��_  H�H���  H�5�%  H����^  H�z_  H�H���8  H�5�%  H����^  H�O_  H�H����  H�5�%  H����^  H�$_  H�H���	  H�5�%  H���h^  H��^  H�H����  H�5�*  H���E^  H��^  H�H���M  ����   1�H��[]��     H�5#  H���^  H�Y_  H�H����  H�5#  H����]  H�._  H�H���r���H�=�"  g�m���������fD  H�5q$  H����]  H�i^  H�H����  H�5b$  H����]  H�^  H�H���K���H�=�(  g�
$  g��������������H�=C$  g��������������H�=$  g�������������H�=E$  g�w������������H�=N$  g�`������������H�=g$  g�I���������p���H�=x$  g�2���������Y���H�=�$  g����������B���H�=�  g����������+���H�=�  g��������������H�=	   g���������������H�=m$  g��������������H�=~$  g��������������H�=�$  g�������������H�=�$  g�z������������H�=T   g�c������������H�=�$  g�L���������s���H�=_   g�5���������\���H�=�$  g����������E���H�=�$  g����������.���H�=�$  g��������������H�={   g����������� ���H�=�$  g���������������H�=�$  g��������������H�=�$  g�������������H�=�$  g�}������������H�=�%  g�f������������H�=U%  g�O���������v���H�=�%  g�8���������_���H�=w%  g�!���������H���H�=�%  g�
���������1���H�=�%  g��������������H�=j"  g��������������H�=-  g���������������H�=<$  g��������������H�=M$  g�������������H�=�%  g�������������1�H�=%&  g�g������������H�=6&  g�P���������w���H�=%  g�9���������`���H�=�%  g�"�������K���f.�     H��Y  � �    H��Y  � �    H��X  � �    H��X  � �    H��X  � �    AWAVAUATUSH��(@  H�_L�-�Y  dH�%(   H��$@  1�H��Y  H� �    H��Y  H� �    H��Y  H� �    H�JY  H� �    H�JY  H� �    I�E �     H;_��   H��E1�L�|$L�%O%  �>f�     <u��   <vuI�E �    f.�     H��H��g����H��H9Ev;�{ou�H�s�   L���t��C<W��   �<Ou�H��X  H� �    뱐E��tJH�-�T  H�} �:V  H��V  H�;�*V  H�U  1�H�8�HU  1�H�} �<U  1�H�;�1U  1�H��$@  dH3%(   ��   H��(@  []A\A]A^A_�fD  A�   �%���D  H��X H�K� ��u7H��H�L$�   L����T  H�L$H���t$H��V  L��������D  H��g����������H�D$H��1�H�=Q$  g����H�T$���H����iT  �U1�H�w8SH��H��X  H�-'V  dH�%(   H��$H  1�H��E H�σ���	H�.X ��@   ��S  �|$? uWH��x0  H�\$@H��H��g�/���H��g�V  H��tG�u H��g�%���H��$H  dH3%(   uJH��X  []��     1�H�=�#  g�������������4U  H��H�=�#  H��1�g�����������zS  f�UH��SH��H�?H��tH��@ ��R  H��H�;H��u�H��H��[]�%�R  �    AWAVAUATI��1�U��1�SH���+T  H���ZS  H����   D�uI�Ǿ   Mc�J��    H�D$H���<S  H��H����   1�H�5  ��S  ��~}��A�   L�-�T  H����    I��I9�tWK�|��1�A�U J�D��H��u�H��1�g����L����Q  D��H�=�"  1�g����H��H��[]A\A]A^A_�f.�     H�D$1�L��H�D�    �?S  L���~Q  ��@ H�=z!  1�1�g�7����D  ATI��1�USH��1�H��H�T$��R  H���*R  H�-�U 1�H�5  H�E ��R  H��S  H��H�t$�1�H�u H����R  H��tH��H�T$L����Q  H��L����P  H��H��[]A\�f�ATH�wx�   UH�-mU SH��D�U E���  H�=5E L��x0  ��P  H�=!E g�[���D�M E���(  �   L��H�=��  g�	���H����  H��S  H�=��  �L����P  D�E L��   H��H�=A�  E���   ��Q  H���*���H��S  ��U ����  H��R  H�=�S  ��E H���@  ���@  ���~  g�H���H��H����  H��H��R  ���@  1��H��g�����H��R  �1�H���{  [��]A\�@ H�=� g�#���H���<  H��R  H�=� L��x0  �D�M E��������  L��H�=��  ��P  H�=��  g�����������    ��P  H�5+�  H��H��
H����������!�%����t��fod!  �����  D�H�JHDщ� ��/   H��H)�:   H�L��f�
f�rB�UO  L��   H�=��  H����P  �   H�5��  H�=zR  g�$���H����   H��Q  H�=]R  ��D���fD  1�g�H������� H�=Y�  g�#����H���H�=�  g�����������f�     H�=	   1�g�����������l���H�=�  1�g���������U���H�=�  g��������@���H�=L  g��������+���fD  AWAVAUATUH��H��x0  SH��L�%QR A�$����  H�~P  �H����  H��H�IP  H�=�  �H��P  H�=�  �H��H�fP  �H�5v  H��H��P  �H�]I��H;]r%�   �    H��H��g����H��H9E��   �C���<Mu�H��H��g�8���I��A�$����   L��O  �KI�W1��H�5�  ��L��A�L�sH����   H��H��O  L���H����   H��O  �H��tH��O  �H��O  �L���yL  �L���@ 1�H��[]A\A]A^A_��    H�YO  �K�L� H��N  �8$~M��I�WH�5a  1�L��A���[���f�L��H�=K  1�g������g���f�     H��N  ��f���f���I�WH�5  1�L��A������H�=�  g��������R���UH��xSH��H�_P �Vʋ W���taH�
H�TH�_MEIXXXXH���B
 H��XX  f�B��I  [H�������1���x@  �	  ATH�5�  I��UI��$x   Sg�5���H��t8H��   H����I  H��g�f�������   AǄ$x@     1�[]A\� H��E  H�=o  f.�     g�j���H��tH��   H���LI  H��g������u�H��H�;H��u�H�E  H�5p  � H��H�3H��t$H��   �I  H��g�������t��^���@ 1�H�=O  g�	���[�����]A\��    ��    AV�   H��AUATI��USH��  dH�%(   H��$�  1�H��$�   H����F  H��
H����������!�%����t�������  D�H�JHDщ�@ �H��H)�B�A��H����   /�  L���G  H��H����G  H��tuI��@ �x.��   Ic�H�pH��Ƅ�    �  �)F  L��H��   ��G  ��u$�D$H��% �  = @  ��   �'F  �    H���oG  H��u�H����F  L����F  H��$�  dH3%(   �~   H�Ġ  []A\A]A^�f�     �P��t���.�I����x �?���H���G  H���#���돐�/   D�jf�D �����D  g�R���H����F  H��������Y�����E  D  AU�   ATUSH��H��H��   dH�%(   H��$�   1�H��$�   H���,E  H��$�  �   H��H���E  ��$�   �m  ��$�    �_  H��H��H����������!�%����t��H�������  D�H�SHDډ�@ �H�5�  H���|F  H)�I��H����   I��f�L���E  H�\H���  ��   H��H����������!�%����t��L�������  D�H�WHD��   �� ��/   H��f�H����E  H�5  1���E  I��H��t-L��H��   �LE  ���d�����  H���D  �Q����H��H��   �E  ��tCH�5s  H����E  H��$�   dH3%(   u2H�Ĩ   []A\A]�f.�     1���@ H��H�=�  g�8�����D  AUATI��UH��H�5�  SH��  dH�%(   H��$  1��E  L��H��H��g�����I��H����   I��H����   fD  H���D  ����   H�ٺ   �   L���1C  H��H�����   L��   �   L����D  ��~
fD  H��H��t�H����3A  ��@u�H�t$1�A�<$1���A  A���     �߃�1��A  ��Au�D�%�D H�-�D E��~1�f�     H�|� H����?  A9��H��   ��?  E��x�D$�ǃ�tz�G<~��?  �H�L$dH3%(   ��u_H��[]A\A]A^�1�g����H�5D L���QA  �������D�%�C H�-�C A�����E���Y���H��   �&?  ������?  f�     AWAVI��AUATL�%n<  UH�-f<  SA��I��L)�H��H���/���H��t 1��     L��L��D��A��H��H9�u�H��[]A\A]A^A_�ff.�     ��UH��SH�
<  H��H��H�H���t����X[]� H������H���                                                                                                                                                                                          MEI
 rb Cannot open archive file
 Could not read from file
 1.2.11 Error %d from inflate: %s
 Error decompressing %s
 %s could not be extracted!
 fopen fwrite malloc Could not read from file. fread Error on file
.       Cannot read Table of Contents.
 Could not allocate read buffer
 Error allocating decompression buffer
  Error %d from inflateInit: %s
  Failed to write all bytes for %s
       Could not allocate buffer for TOC. [%d]  : / Error copying %s
 .. %s%s%s%s%s%s%s %s%s%s.pkg %s%s%s.exe Archive not found: %s
 Error opening archive %s
 Error extracting %s
 __main__ Name exceeds PATH_MAX
 __file__ Failed to execute script %s
      Error allocating memory for status
     Archive path exceeds PATH_MAX
  Could not get __main__ module.  Could not get __main__ module's dict.   Failed to unmarshal code object for %s
 Cannot allocate memory for ARCHIVE_STATUS
      Cannot open self %s or archive %s
 calloc _MEIPASS2 Py_DontWriteBytecodeFlag Py_FileSystemDefaultEncoding Py_FrozenFlag Py_IgnoreEnvironmentFlag Py_NoSiteFlag Py_NoUserSiteDirectory Py_OptimizeFlag Py_VerboseFlag Py_BuildValue Py_DecRef Cannot dlsym for Py_DecRef
 Py_Finalize Cannot dlsym for Py_Finalize
 Py_IncRef Cannot dlsym for Py_IncRef
 Py_Initialize Py_SetPath Cannot dlsym for Py_SetPath
 Py_GetPath Cannot dlsym for Py_GetPath
 Py_SetProgramName Py_SetPythonHome PyDict_GetItemString PyErr_Clear Cannot dlsym for PyErr_Clear
 PyErr_Occurred PyErr_Print Cannot dlsym for PyErr_Print
 PyImport_AddModule PyImport_ExecCodeModule PyImport_ImportModule PyList_Append PyList_New Cannot dlsym for PyList_New
 PyLong_AsLong PyModule_GetDict PyObject_CallFunction PyObject_SetAttrString PyRun_SimpleString PyString_FromString PyString_FromFormat PySys_AddWarnOption PySys_SetArgvEx PySys_GetObject PySys_SetObject PySys_SetPath PyEval_EvalCode PyUnicode_FromString Py_DecodeLocale _Py_char2wchar PyUnicode_Decode PyUnicode_DecodeFSDefault PyUnicode_FromFormat   Cannot dlsym for Py_DontWriteBytecodeFlag
      Cannot dlsym for Py_FileSystemDefaultEncoding
  Cannot dlsym for Py_FrozenFlag
 Cannot dlsym for Py_IgnoreEnvironmentFlag
      Cannot dlsym for Py_NoSiteFlag
 Cannot dlsym for Py_NoUserSiteDirectory
        Cannot dlsym for Py_OptimizeFlag
       Cannot dlsym for Py_VerboseFlag
        Cannot dlsym for Py_BuildValue
 Cannot dlsym for Py_Initialize
 Cannot dlsym for Py_SetProgramName
     Cannot dlsym for Py_SetPythonHome
      Cannot dlsym for PyDict_GetItemString
  Cannot dlsym for PyErr_Occurred
        Cannot dlsym for PyImport_AddModule
    Cannot dlsym for PyImport_ExecCodeModule
       Cannot dlsym for PyImport_ImportModule
 Cannot dlsym for PyList_Append
 Cannot dlsym for PyLong_AsLong
 Cannot dlsym for PyModule_GetDict
      Cannot dlsym for PyObject_CallFunction
 Cannot dlsym for PyObject_SetAttrString
        Cannot dlsym for PyRun_SimpleString
    Cannot dlsym for PyString_FromString
   Cannot dlsym for PyString_FromFormat
   Cannot dlsym for PySys_AddWarnOption
   Cannot dlsym for PySys_SetArgvEx
       Cannot dlsym for PySys_GetObject
       Cannot dlsym for PySys_SetObject
       Cannot dlsym for PySys_SetPath
 Cannot dlsym for PyEval_EvalCode
       PyMarshal_ReadObjectFromString  Cannot dlsym for PyMarshal_ReadObjectFromString
        Cannot dlsym for PyUnicode_FromString
  Cannot dlsym for Py_DecodeLocale
       Cannot dlsym for _Py_char2wchar
        Cannot dlsym for PyUnicode_FromFormat
  Cannot dlsym for PyUnicode_Decode
      Cannot dlsym for PyUnicode_DecodeFSDefault
 pyi- out of memory
 _MEIPASS marshal loads s# y# mod is NULL - %s %s?%d %U?%d path Failed to append to sys.path
    Failed to convert Wflag %s using mbstowcs (invalid multibyte string)
   DLL name length exceeds buffer
 Error loading Python lib '%s': dlopen: %s
      Fatal error: unable to decode the command line argument #%i
    Failed to convert progname to wchar_t
  Failed to convert pyhome to wchar_t
    Failed to convert pypath to wchar_t
    Failed to convert argv to wchar_t
      Error detected starting Python VM.      Failed to get _MEIPASS as PyObject.
    Installing PYZ: Could not get sys.path
         base_library.zipLD_LIBRARY_PATH LD_LIBRARY_PATH_ORIG TMPDIR pyi-runtime-tmpdir wb LISTEN_PID %ld pyi-bootloader-ignore-signals /var/tmp /usr/tmp TEMP TMP       INTERNAL ERROR: cannot create temporary directory!
     WARNING: file already exists but should not: %s
    ;(  D   ����D  ���l  $����  T����  �����  ı���  $���8  ���x  ĵ���  Ե���  $����  d���  ����,  4���|  T����  D����  ����  $���   t���|  �����  ����  ����  ����h  ����|  �����  �����  D���  d���$  4���\  �����  D����  ����  D���@  T���T  t���l  D����  T����  d����  t����  �����  ����	  ����T	  �����	  �����	  $����	  ����$
  ����T
  �����
  �����
  ����
  $���  4���   T���4  4����  d����  t����  �����  �����  D���  d���H  4����  $����  ����
 AABJ   �   ����1    Y�W   H   �   Ю��`   B�B�B �B(�D0�D8�G��
8A0A(B BBBH<     ����    B�E�B �A(�A0��
(A BBBF   8   P  �����    B�B�D �I(�J0�
(A ABBK    �  ���       (   �  ���P   A�A�G �
CAB    �  (���7    A�u      �  L���1    F�d�  L     p����    B�B�E �A(�D0�O
(A BBBDM(F BBB       T  ����           h  �����    A�J��
AA$   �  �����    A�M��
AA        �  0���   A�J��
AAx   �  ���E   B�J�B �B(�A0�A8�G���c�M�A�S
8A0A(B BBBED�M�O��H��S� 8   T  ���   B�G�A �D(�G��
(A ABBAL   �  Ժ��K   B�B�B �B(�A0�D8�G� �
8A0A(B BBBF      �  Լ��       H   �  м���    B�B�A �A(�G0\
(D ABBNT(F ABB    @  d���          T  `���           L   l  X����   B�B�J �J(�A0�A8�G�`z
8A0A(B BBBK       �  ���f    A�O� N
AA   �  4���    A�P   4   �  8����    B�D�D �f
ABELAB 8   4  �����    B�E�A �D(�G�`�
(A ABBA   p  D���T    G�F
AL   �  ����5   B�B�B �E(�A0�A8�G�@
8A0A(B BBBE   8   �  x����    B�B�D �D(�G� [
(A ABBD     ����          ,  ����    DT ,   D   ����
   A�J�G 
AAI       t  ����	          �  ����	          �  ����	          �  ����	          �  ����	           L   �  ����/   B�B�B �B(�A0�A8�G��~
8A0A(B BBBG  (   ,  h����    A�G�J� �
AAI$   X  ,���9    A�D�D eDA H   �  D���+   B�B�B �B(�F0�E8�DP�
8D0A(B BBBK ,   �  (����    B�F�A �I0t DAB,   �  ����
   B�J�H �"
CBE  H   ,  h���    B�B�B �B(�A0�K8�D@>
8A0A(B BBBH(   x  ����    A�E�D j
CAH $   �  ����Q    A�A�D FCA   �  ���              �  ���          �  ���       H   	  ����    B�B�E �E(�D0�C8�DPa
8D0A(B BBBI    X	  ����/    DW
MF      x	  ����       $   �	  ����h    A�K�D SCA   �	   ���          �	  ����P    A�E  8   �	  0���   Q�K�I �|
ABD�FBH���  D    
  ����   B�J�B �D(�A0�G�!4
0A(A BBBJ   <   h
  �����   B�G�A �A(�M�A�
(A ABBK   8   �
  L���e   B�B�D �K(�G� �
(A ABBE   �
  ����          �
  |���$             �����    A�K0r
AA @   0  ���   B�B�E �G(�L0�G@�
0A(A BBBAD   t  ����e    B�B�E �B(�H0�H8�M@r8A0A(B BBB    �  ����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ��������        ��������        �p      �p      �p              Up      �p      �p                                   f              �                                   
       Z                                          p�                                         �             �             �      	                             ���o          ���o    0      ���o           ���o    �      ���o                                                                                           ��                      6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        �      GCC: (crosstool-NG 1.23.0.449-a04d0) 7.3.0 x�ՒAN�0E�$m�&;8C��[����'`S�tc��D8q�&H�F\�;Ċ�e�0���y��lˏ��`ԇbB)!�O�XwX�P �:Ѕ�S�!C_��M�`P�	r�	��5
=�k�~�uz��(M
�
c����scӋS�4�������A�M�$��`@jx��8�G��ɩJ�C�e�k��a�
���o�b�\G	��$��9I������(��(�
�@ɂ֮�/��@��miQ��4��%u�&+L�GǢ�C5M9Owpp�A�"���:Wґ5��4qt���P���r_Ŭ)�:,��A��� ��k����sFaS��3���fv�`�ʈe��s��!��0�j���
�$�N�=����� �Υ6�r䧂��)EzJc5�D�`�ǁ�����1K�������d��(9���������6&Sv�fM&�1����Hp��
U���������������@VgT��!cd�-�M�p0�IcT5W�B}�� T
���:/��������* ?�N&��ԍc�l��S�&,����-�%��zEs�(y�;��m�4-���� ��Mڣ(S��M��s�{�$�H�ҝ�$�#?�UW���eV~��*���j�`c����3(�/2K_YO�R�$qɾ7�%J�s�<��[`�m�U�^c�;��Fũ�+�S�M�o0��zx��YMp�HvF� EѴ�=�]f2�.[�=�Ļ�-�^g<�V�̎�;��P�Ht�i�jSk�֜�{�e�=�ʗT*��-�����*\R��|�!�\6�@����1�� ������{���W��w�����(��L}t��	|㿃�S<�U��Ț��jS����|uG��7O���&�M#���4<�Y���Ͳ�6+����o�����f�K�����y٫�yů��	8��p^��u8��jp^��p~«�yݯ����+���qk�Uh_ױaд��f=����`a��y��}�4uO�Ɍ�t/���Q<�*6|�l���qlw|�ۂ����m���mkG�;~K���s?�C�[�zvk�9���(D�4_�.ݶD�-V��b���uڏ��n�q+��5��j���s�b����+�����#�E���9���ͫ}x�m�܊BϽ��F������}t㣛��Ჳ���s��u[�v���?�Z����]��זn.���+}�6wˏ��w���n������� �ы��8.om����nb9N�q>���ɄLuXO�c)��6cC��;NRq�i���U�y6p�镒�xQ�q�<�D;Uh���\�f1]���
���<����ѵ�X�㏔�*ʗ2�ç�?�u��!���*�~ ��
DS;�B��e 
�4�.(�������qL p���l�H4�gK \$Z�'��>�;@��(�`o$��ܭ�������I�Їa�y@}�S�f�6��6�ݤ����V���?���A�h8����[�tR$� M��26�I�5lnâ�ŭ;O�$�(S�NU)4[j���㹕����w�]�Rv��
��4�bz�!;T��Xa$KǕ�uP���g
�#' ֔O��}Y����
�����|m	�?�OґD�z.�����Ά�D.��2T�^���5��Ǹv�]�	S�?z��pӠ%sb����t/��R:;�1׋�R}ͨݎ}1��ͯs�-�fg؂�co���
}�
�+��
�ބш���(O�D�������+H0�@�fG���� ���V,��|��̟�Y ��ߋ��
�
!�F��x'��ed9h���J��W�7r��
:ֈ�7�+Jh
[�g��3�ua�X���_�	�Ձ�t*�/��8gq�S%T���d����#�=e��<�6�Ox �'%{n�>N
��Q=���`h6Z
����Y�7埕���qYUOYT<��Z�J�ڢ�z�X/,��ESU|�Y\���om��6�M@	�[�Q�+�)��+/��rs�b��'���?R���Ԏ򪲥B݃�nz�Pxֳ��G�bų�	���fg�����A(��G���|�w�<�<�~╽}P����*��k��ߛ�H�&��[��p����)�w���7
��q�<�r_]����Z�U�5�jp�_X���\��ʘ&���n'Ė���I�ǎ��kزd�m��7�쨪��T���V��T��z���85�����]��\����;:�B�`=^��W�I�7U�e�,gvϒ�u,�Q����K8�_Ta6 ��<�3>R
�7:��P~5��Vq���c����n���J9���֜�#x#;���� @C��ϔ772U���z"��Y3~���j�I�m�؂���^�56v�Yf�s���)��H��V1���^���Fd��$t��t��9R]W塔�nJ�&U�t����hv℔�=�	�M��rVfԭ,I���pq_U>��&���z�p�Pa��5�a��Mk����[+�= �-Mc����/���
���ȌA�B�n�q����F�܋LDa������X��L�޹��@B�le	D+qn��@�����@h��G4��=�҅|ρ�4Vy��Pc�o������ы�|��z "�uF5h dDh~� t�O�1�VY�P3UkU+�a�`#צ����ׯ�3���t�����iQh�t��
sN��=�]?��,IC��
q�h�+d�r�2k��0~	���k��rq�ǅ��D��4B�����|
?��5<xaPf5��3;p"��d���}ˣ=��<��P�:���%�Mq�$l`���Nb����hFAH�(Z#�0�����c���B�]�� L��*�T�H{hh�P�,u�al߂O[��F������	ol�wlo?w�|豢��F�6�W7�޿�~2��w��W5_�6��W1�^	��}�^�l9��'�z�����2Ⱥ^�o���N��GlGC��g��$�b��3���Ɂ���}�+~�P?��qT}���L���!D�0GHg����H���i>� �Z�.Z�!���!�X���p�J���$�7릊˅0kiX��_�r	�*vD��r�OQ��
Y+��%_�87���+E,�ѱ���s{����>?�Y{b� �  P.N"&�n?K	p�C��A1norQ�3A��/���nK4�ͻ�iP��&�� Xx:���R0�zd$R���$�K$��=�#%iex��2F�b$  ����ut���^��{�Vo��'�2�7&#DJ� g1,"���Qz��Ma9jK�=pа]�����v7�{A,N�8N�	����.��'	���[[I-F��"-F�T*�Zd�zY��IͲ�c��i��6U��0�*�zY��Bٰ�]�����]o�i��*�틽J��	A�o(���8����������7���&҈��&נ#AQ&���j�����������"��J� [S+�;����z�{��3��e�)�ۡ�<�[�7-�8'!���_��9u�8�Q# M��kC��r�F��G�!�'!GƄ��hz.h˴[@�t��CI���!�,�\�1���Q+����t�:�N�꽝l�oqX�c��YN2	�Ds���`�/w�W�bZD�η�[S��6�����C����?UeңHI��ch�{��{���$�=QqVv�x:1>vK
/|OP�MMz�,r3 ��\꫞��}
�S�+�M�<��2���]ڻ�iOe-q�V�"�'�)�{Q���S��8��.���Vs'R�\7q	�-(JJ����"f�`h={����l����##�_�ќ͒�a��:(����J�n�>�#B��ۻD��Y�!��pF:��kRC9�蟬�d�	y�quX�R�-�Ռ��^6�+���ghh�h�|fYg"��ѩ�|���k����E\���tbLc[�,��C�bn=u{���
b'{:�A`En�^H�faG�T��Jxl�;/ļ�r,{�F�;n�����~Wbh��
�ei��D+E���Z�E���3
O7�-��4�"�3�O5U���Mu\���1�)[k��F�rE��稛F�'��18�S��;"��>n�1��8��H�\����q����ƅ~�b>e��l��,�Q��b��bGd��Ə6.�
[�43�!7�5�������EB�q%�
��__��?+~�w�n͹̳��`z�.7��'u�M����y�Ykr�rj�(�"�i��s�I#�|<?VBN��!�a�T� N�M�f~��1�"4�z�kL)�!:d���0$�o&e@m�8.2=�3�'����ϣ��G��g��̾��g>�5����y���\3-y�X���2�t#Z�	��
�y#�+���ؾ9�ݾ���s��E, [ -�����Z���x!
���0�[��*�7���u����6^<2�r��@)�鿣��xʌ�aLl�Y>^fh/�={e����i?7��[E��v9Û_х�����`���d#a<�)ȃ���,o9��Iwj"2�?��Ę �oB���V0x����X!�_v;�d�9��Jn�0�՜�C�F�� uVVW`�0g�N�H��� ���J�	t�x2v$�$6-f�m@ܷjZ��ٮU�g�l%1�͜��8Ŕ1~�3 D& +�/�]���:�<A�a�O2C�����@_|郰��x�X��O'�"�DrV_&iM���9�ohz�ir#��މ�*�ˍ̜�7ȍl*��T�Z�ҔhM{`���K�5<m�`�HmZ7V���C���Ht��������]���{��9�17�GdE���֬�SX��P� p=1JT��lG�N��,��O�`����h�v�F���R��\&�,�S�%��@����i�n�i;�2,&jB�mܧ#��ܕ��:y[�t�ס��p7
�����/�rdn���!ħ�\A�0�Y�"X�6c"�g&=ND����ړ Z!��@��A����/L
�?;t�%��a�(�aƽ�x ��[8Te����c0�Tv�~�kW�\�9����ual�ZǄ֘�G����Xj�jL>�N���^�g[m��75?Ǐ�޷�N�`�����ۅ��0�&���$OAs�`�(ca2�����Ii�N&�掶i&�)"��d�v��|a����s"��>�-�m�;�>���<�.*����*���0�l�7��;�}n��7Ue��
��
{���-�9��qv{O�/����n[�]�_�Lk�*Zez������(v�gf�	�#Bn��-eS���ّ��M�3so�f��?�{X�Y03-��f��j��P�����#���V�M-���[h䝃ze���tτ:?����^+��qd�d�����@y�*m�q��"w�i����%螒��`��Q���^Y���6�*wgq��+�a���#�"��:a(���t�<���;�3|�#
�.X�8-��ǝ�ĜK�Ivk[ڮz-�2纭��j\p��^0�Q#�&�6���->�d�TS8i�\i�@i�`66�Il����
��U�{�S���;�k+����{wVOP���,C�C|!FMH���4�(�C}�'�XϬ�c�������d%��4�^�-�f����]]����7=����b/|P�Ts'�\M�i�nj��Cc;���Y����L��,���0��r*��v��U�#^'��!Cf�up������D
It�u�'�릨S~v�6&x�pw�G~ig�E��� 
��ܑ(e�oR^*���J)�w��n�WUS9��k���o�p��ߝA���&���9�Ǽ*���xUsi����{.��?�Z�{�+���3ؽ�%�^�^%�)z��iئ�����_�ٿ�f�^�Y%��)ft���U��T�lkKT����8�uP�,�t}��`\Ȭ���[+�۞�}8Wg�i}b����B��Vw���R�'����*�U!�e�O|�2����Q����W�
:���+��xq��� p�E�Z^};�ʁ/���aaW]���ʃg��J�����B�
�c�)��j���\f(�Ԁ4³���� �T�_R�����e�6s���8�e✑Kz\0�����4%<E�Y	[
I�ٸD�l);n[8G����gE���X�7	X�4q)S���u�z�x�]PKj�0�����t�+d�� 
�q��H��L���L��;�3�6�w ��8�M��uXE�n|��i]�\isk$LxC|B�
ۣ�O��_�Փ���VA��a�y���@�ydS����).����m���� �<��;��-4)��O*�,Ȑ���{E�]`5�\�[�?�oݳ���K�}��
��B��Ҳ^��N?s�=��Qj�N��(
�we��O/i岣��}����k�l䙨����P���������񕎤V{��1��I4���qU�eƏ���ح<�a��l��c��W�Bj�dQ*��%]�
������*�b��v�m��6�TM!ג<�H����V��t6�a�of��B�S����l�����L
�@!y�Z@jN^x!}	��5��"k�x�Y���x(8yE�!�h��z�@�j
�^n��?�O7ʫஔ�4K]�L��R�u��S5����|c�T�'�a����zĻx0|�F�`��¥��9
dx�uT[o���].W$M]#K�,�r���8i�4nG�h�H���s�"�`�s(-�7���� �W�F�L>����>�%? h���]����ؙ3�����?��~3�}�_���iLc$���	uG'�6#4�h�4f��7��~f8��5�_��G0�4�A��}FXuh�YuU�0{BԹV�L[���P��������mmB$Ga�;u�7����R�t��1�e
]ڍ���K+�;�0��e�R�����uK��S.�0��ET��TkC�4��@T݃TV)��w�|.��S���1�c���zC���@�ؒ��PW�=��?̈́��DU�ҵu���	��n���x��ޏp��ق���(/�����b6��^�1呝V�071;�_ή�"!�A�1:�7�XXy������R��1^�1-�g���~(���?�ʱ�lzM��Z��R��&�Qys�O��sfS
�\�()ű
����e�.�Y�]��%����)��|~��<c�~�0~_a�W���
^ n[�n�'�Ip
�	���p������\��������� xx1x</��U�R�2�r�
�x%xx5x
�9pt��>�gA	*P�mp\;`\�_ _______� �������? ???????� ������� '����'ꓧ��k�~-�U�N	��1�U��{�f/����s\�5��+źp��#��t���b���a4v��e���,+\(1�L֘���Q�|�K%|�t��\֙=,>�	M�͗��pU��h)!�W���p�� ��"�f5�
�
wg�`6��ܢ<�p�L�	Ax�d�V�#d�#��uщ����4��L��[Q�V
wd�J��kD�����u�h���@�2:���b�y��TP9/f���(�Vݗ-��n��e�^:�gL����Bq��̆���>�9�� ����k�**�v'��mOtz���W���U�hґ��іZ��O2�+��"�qҕN�"HW�duɊ��^�4)����=/y�_.1���]�􀏸.�G����z��I>+y4ݼXq&�f�J�|�˘l�y�mo �&w�~�4��� \μd	i�UЍ�Ҋv��@��~� ���ԵsԠ5H7�Ɏ��o�d�h�2�U;h�A�����蝰u��H����qE��3��Q��N��+Te��B�稨��؇�tT�\ڑ���qL;Y,�v��]��s��?�tt�?�דg���n��n�ӥ'h�5I��:Ԭ滚b�j���!���S��C�5����+G^M���n�b���w�}�]��P�w���c��"u\���"�4�"-U������qzseM�M�Q�i�}Y����*&����ӪZq�sE��Q�L.��EJ���.h�KD��>��I�M4tHk�'���6�����_(6P\����3ζ��pW�蒈!�QuRǐҹ��c��25�3}r6�<��o�
���(�I�g��k�TγM�< �7��㼍���?�A�*��P0=}!'��x|���G�Hvm���^܊i�����r氀�C4��ܺ
��m]I�j���G��,��rc��y�Ϝa6�����W�@�6e#Y�T��S�"��V5�
�-���Q����ߜ.���A��uY��
�!�S�1_��4�Q���������nIMڌt��U�V*�M�e�Ntq7��n���X�?�S#�ʆ� ���׿v��#x��[lWwv�K�޹a-ֶ.ftR;��Nݕ2�ƉӞ��u�1U��u�sb��"�
I��@�5V����MT�MHH�?Q�!p�Е��	�e�~j2�-]E��;��ܽ�M���i�?�}���~����}��V{��q�C���)�[�|�_V�� �^�iS׍*cn��i�UY�,']v�ڙ�����!��V;<���Ry����4���xb�Ke�cv���Y ������8O�q�Dv�k�$�mBw�l��J�x;�� Ւ�fK�U��M�@hs�k,kj�?����v��Qw���8Wm����kɿ:�,.�uS��V��F���Q�Hݝ�y�z
;,�c�h}��~Sy҃��Ϙ�k�r��J��]~ΔoA>"�F�����\�"oٶ֟�X�P��rz<��b(�LeR(�:�S�j*��ٮ�mi-�v�O��R��5��p7O�Ψ(���v�j|0�fّ!�&��t����Z�&�S!���dVUQ:ujH y���d?.'p�t8im�5�M�>�뉎���㍲\���;�{��ɓ=����l9ONߛ�������M�sK��r�`\�ȭg��E��,r�9�d�WY�+�s^:p�����C����߀�����.,�������F�|�y���[ 7���^9_���:o̙��D�O@ԭLT����(�wt	4D��k��b��`�ľo����=�����K�/�����-�_��/���l��m��fUUƚ��\7���:�Z�|�g@�5��w��L{����2}ۥW�������<�QP�U��~ȸgv�/����r�<H�Љ�b���7�I���9��Sai�{�ַ2��/)��ӿң���ג���i�]���*M���o��BH�Z �`c$�ph<X?�nl����Tt�[��;Z��u�N.�+r����=�Box��%<n��j��kqM:{��C:������9ϙ��N%����ؾ�'�Cɷ���J NJ��[[�����ɰ�m��8Sŉf}s���n���m.��0OB�MH��4��$C��(�))�o$��tRZ�+��B�:�p�V�-T���p�lRz�7��(��dE"�eR���Y��9}!Ph��1�>,o��KXco~.2VऩZ,q��斥�i(V���#<~�D+��`�(4t5P��
7
����3eq���ؗߑ�����ϡ��M}�����m��>;_��~�=]��{2
�?�{w������"c_~��g�C����u��^����J���zD�9���ce�:��^b?��|~��x��[l�?�H�靋�╢8X
��K�6�)��Kr���Ǻ��u���ؕ��*�-��t\� ���iBZ5�Tm�*���"�T��"���"BהҖ�[n�w~�9ߒ�?��c�M��}�����پ�_��E�F=@��ϙ��0>�͉ VM9��n�d����_��)l���F)��z=͟���%���
Q+p>��˚�e�|=+�sz0�@>?h������T�Ӎ�2r���d�B��L�f�o����|N�g1��^)d��a���WG1�1V����=�)��@��"�u�]H�y��.��W�c��%��ܔ~s�4S�e���E�m��/�(�W�e|�ni���s�?7n��N�x �;g����ϣ|���%x��������_t����-����-�߆�`\�p�̂�Ԇ���uL�����X0�
%R� ���z���yC�+�o�I��
OU�U�YE��l�7�7��xr���n�H��:`�kD�g�>�յ�==��g�[�S�t��܌��.�xp�v���)n��gt�M������6��t�����ouxe�I&�d�I&��Ñ8�cb
t�ūא�-�4�5y����V�7�aq`�r�j��)U*��� `"��*�hrr�bĖ���Q1s�&���-�3I���E��:|��Յ���&րn�x�Y@,����d�����i-�'|+��7�4�
͵�,�+`t
�Ip<�+U�A���T��<w�V�Z�$��<��S����a���^)u� p~���h�B�.��������9��]��<0\��Uʹ�O�Tfޣ�Ɂ(�����4Z�=�Q8��"<���
��l:�t��	�s{�)v��:a�g��� ;a����  ��w�� 0�V�4CЇf:������5����}�w�����fv"�/���tJ�|�X� ��j�!�w4W�0x�f�`h�3�fb�P��ơ�R�
:P��ީ\t��4Xrk��d�%�B��l�ы�&3=�^��
3������qPM�X�4���©�(�\�0��q �������o�ϑ?���r�I��:�><�y��ʅ���(q[F�E���Z��9g<x۸��?�l�:�>���f.@��k�[��+As�PV� M�%��OE�Q�9R��!=����xH�T�
f�0�C�tY������B��R��/�YT#�����ˋ��q��}��M��m���I�By%9E��)�.y�]d�?`�쒸T�X&�Hb�� ^�!���T��Mռ�Z*m��Һ`��E%���l���u�c�)
^ tg�I%;>�6���Bꗮ�~館<��[��|�_:�o����9�~�U���ʬ}�H�g�Ԭ�U����5�̑$�+��t��^�X{9y_����q����Q��[�{����RU�8�*�{�5����4=.����f��=��70	�@�!5eWOM^��76t_m�7���$�L2�$�L2釧𮝡X��[��cw*�ށ���o�Ͷ=�֞YL��6`N�{��/��A��Q�s�YU�����
y�z���m��<]c ����r��x풪jo�z����v��4�o���g�;h�>k3�Rl��g�`�d���.�uVF��}��4�L��vŶ�j�[�/㟧�������	=��,��3݇Q^�(/?ʫ�%���P^��&�N�����0�7�I&�d�I&�d�I&���i�>�+����1���0/%�x��L�������v���8�øO��UcA�gn����:�'{~]���z���:��.�
��PL�`[{W;��o
��c���q1��T��
ׇ�;�Z��-���!d �Ѿ;L�DB�_�	�E�h	utD[晭���"�ba�h��%��[SPˎ`KdG�-��1/�w�$:ڛ��H,juǣn�nAg?&j�ʪ`��<sV澃p=���j�;�Ol���^'�x�������c�u����$�!���оi���8e��:=x���
�)Ѣ���Br�o�� $�^@Mkg�K�ɍX�ڤL4!9d_H���W��P2� �笂4
�W��ܜ�Pɰ_:,�g���X\��7g%%Hy��E�S
O���t��M ��6
xD��c��c�;
���Ūo
r�k�:�J!g�$�l��q_ I�F����cK�d�V��Tl��$@�M{AeOPJ6K3g#�e�% $R������ ��Q��NV��.%������M5q[�&�.8��AF'e�#��D��8O�烩F��YD�� �h=����|���6��WS�.��̕g��)�7�b���
+
ӗn�;
)�&��FqȢڑ�X�sH\���m�~1�R��v��d�FA�~���rF�$U	��=����Tǚ5(Z�UX�PS�
�g�y�
�8X;]	��%��zE��-�׶xS�q�d3�+y��E~i�U�J�T�6�}�-$J��{n��<BRt��Va��U��C�(���J�B.�B^!ok4�'����S�J���u����B�V��H؞<����L�l��!�$y%Hg�AV56��SţJQ�*���E�5��������T�hJ���2�J��eU�RT�
���~�ȳJ�����{�J|�����
LuE�)cSg�46
zy����`삢lC�_+�N�>��� O >���ǃ��A��ɒ7:��Ahs�&��Q���n����<N���p�mk\���p�E�9�3a��h+|z!�:� ��f��T�˟�V�Τ��.>��ў}�<]��[�hYJ{��bh!�����H{6d3��A���S���^�MZ����~ڹ���ŉ� ��l��9�����coGhO"o��5i	-����5Z>�`3}�>K��l ��o~/��g����'i���l]�哀|zI���t8�}�Ѽ�LY��06�3b�f���]J�Mm,Pe~	2�A��L
q4���L���R���K�¾�e��+]��qqr�
?�k���kiw�U��dP�����eӏ];n�
�9Y��f��dK����|��a�0��oX��aܺ��lĎ�exx\��|Y�Hz�k�^I ���Q�<��%�w�`N�l���$~Dΰj&LU��`�z�5���z� �0���+ɦ�3���`��:.ȩr���}�h�3�*D�+̈���o]Aҷ�Qǅ�B�d��"�A뤎wO/����pۤ\T^�Hy�W�����"��9w=:<��z/����G��T�c��Z��z�c��������>�~�6��Z6�&�ݎs>��.A�P��v\��{���m0z�M\Bᜃ�d:=F=�m|M�m��p�&��s�n�7��8V푎`#�q��Y��F�����;Az5�3d��z�,\��g3���|���rY��Q��_;���Sa���2u�c���|0��9i��Am�a��4]��W���|P/���)�k~�%sJ����	J�e��Sd,p50h�5�E��m�E^^��:��d���D�vH?J�n$���앓ҕ���7Ϥ�M�V��؁vӱ����A/�A��F������ҟ�G��Գ�%S���H��x�3ʞa��>F�9^��yĨlJ6�vO�\ۙ��Gg�����!�b���S�X�xA���.�ͣ帥�ؓ̇=1�`!��f,�U���d5��M�+N����7���=|��ï�]�ڨsj�^!iLH9��2f�|�e8�!��-���Oꑾ�N�=��J=ǥ��8j��ŘnBx�V��uT��PN��mJ"ǖ.Pѓ4�3�ʎj_q��
�yӵ�^�dOF@�r�%�A�N����*�{ڨ,n�.}mTŵ�[�tn�-k�\C�mSͻ^t��f����e��V�|"��zF��1D�=Mr���1�-��rZ7���6�=�Y�=���nb6���i���4��V���N�A��6Ϧ�:��b9��xY8��X���V=X·�d��0k����X1�F�5�M���o����#6�����&6�.�Y��o���qx�&7��W=�gS{��v^19�+i��br��	���k��������8��r@�ɆRz�D�s����sԷ:`�b���];~�+&�\~�V���t�ux����v�F��Y�	W{u��k��4�ѵa�S_��k͌�Qxj���-��$h����6�ɚ��|'I��\R�;�dQ�!��F�gu:Ĭ�JQ���9[Z��/n��|�����e�j���\p��X2������~8ɺ#��T�1:[�R������C�s'���\y��y�qH��kc��)lg�$7H�� ��N�b����v��S0 w��B�z��Hr��i�sXI�oJ�g�9�۱�㰒b����T7�Q�J��M��Z��BϚ�DaT_���^wW�R%Ĥ+��m���B�<j�!�t�W��]�����X.a=�M�`����4^=ތ��G���i��,0���7��k5!�N۔/�s4V��x&�?bN4O�v��h�P�W>J��{]�;;+���}�=���<eι$\����|(7EȾ�]�EN��I���>�`%���G�NC��tz�j�g�[�n�5�j�M�%�侩)�_���TuL�����M���T�i�y�䚇����bu�tD�)Y��{�� GNr4��X�d�k��EiX��nꝭ�{ʡ�vu�w��p��?r�^ڿ͜�z�2�O=���W�<����<���3�]M�iR���|�M7���?����4ڿf�o���X}U���?�tB����%�&�"��lJ�\4��Is��<ڄ#SF����d�Y��
r/����<W�.�=�	���LY�^�B��9�b�)�m�y!j~J5����;v�HWq�?�
�桐(|@v�1���)W��A�Kߚ�q�����,���d.��F0�j��u,C�r�ef#7�{�^1�%�b��d����D�H�[�%�z9F�Hw�]81�1���*����Lc��b�����c�n����������������3��zA��l�rm��iJ&�o,u��2*��y��A�Xf]�j�ʤ욌eS'��O
��wpK���q�iUD�oӪ�̩�+��L�6��A��ӪM�ĥ#ӪFu*�-��j*��yUt���zӼjb�yU���̫��U1��Ϋ��Q��XѦ9�D�WѦ���뼊g75)��@v�S�yV���cn5�ܢ4���U�<�q^�c�Wud^��<�J�yU�$;A�W�b^uP�U��yU�*��ϫ���[����2�jU_��_�ҵ���keP��c����S���Dq�[�h�ǿ�WC"3���{;;�?��jPlX��%ko��siuGoGC�g�Ъ|wՎ�����KvԎ�cm�iv{�}q2����.�'��:��o�<3������(�ȝ�TV(���$'�Dz��.�oG�H5����)C�a�mÞ�bo[b�X�G�g�����c��c�"�����Gq���M����7{�Kv�d�l����:k�F+�1�^ɪW���1=,�J;Y,Yi���i�+�ҰX+ɗ��V'��޶5DV
tQ���Ycu��ް8��[���W�j��W�2"�����z�NK|��:)l���uU݆�����7��U�b�����?����.�Q�P7�wGQZ��W;�
׉Մ'1��B&<��D.��(A�&�Dg�1�XC�'�
��Y�~]�
.��`t��1��]����p�K���d�5#�~�5�o�U(_A��9���p�Xn��(��5?�	���/�,���>�ϝG�[RܪÞ7�kto�5�qP)�c�������/�]<zͣ�cx��u����P��n
 ��� �! � ��� � � U�Q p � � � � T C @  	 "�% P
 � �< �o  � �M ` � V�� �1  ��U � < ' �4 � < k�l p �
 ��  �	 D �	  ; � � G p \ � @
 �
 
 j�� @ � � �@ � <�( 0 l K@ � | } @
 8 �� � �  �p ` & �� �W 0 � �m �% � ^�} � � Z �V �6 x � �� `	 p � @f �	 � � �# 8 � �� �! � �@= ` ��3 �
 �� `9 � � � `2 � �� �8 � �@4 x � �� P � � �� �+ �
 $� �2 �
 F �- �g 0 t { �Q � .�� �
 h
 �� ` h l�v 0  � �# P	 �  ( � �� �  { � j� � � 6��   � U �	 � �� � � ^ �. � � @} 0 X�� � � � @ �  �  ���?�/��WG�k�������C���߀�OD�ߠ�M����q�;��/�������8�����F�m��<��~���o���G�'�������<�����OF�������]����������ߍ�A�ߣ����)��L��9������E����[�����x��,�_����F�������U��+��1���gF�O�������τ��@����u��N��^��6�?����7B���������g�??��W����&�?��7�?�_���@���h����E��'�����ע������6��'�� �wC������6�� �?�D�ۡ�.���?�����B�����9��	�o�����?C��@�ߡ��=���7�����(�?�����C�s�����p�����?��B����9�����
�����?���@�o�������+���A�[����M���߉�WE���y��=�I�?����ۡ����n��p��<�o@��& 5<�HNj=R����`�(5#�	I�Aj(R��z��֤�$u?�iH=AjsR'���Ԋ�$54��IJ�RO����d��#53��H�Bj�R�����ۤ~(�H��H�HjDR/�ڌ�դ�!��JMPjCR��Z��~��#���H-Jj)RÑڠԡ��)5��I
���_�m�ڵk�q��o�7ԨF��.�~r����K��^���N��/�{θq�i�bgO��[��Ӻ�]]���ih���QO۷?���_#}��qy߾
 ��# �w � � � @2 �  ��� �/ � �   @ � >� �8 � � �w �8 � +�} � � .  � ��� �g  ��l �	 � Y @. 0 � �@	 �  Y@ ( 
 �� � h ��� � �  ��R �. ( �� �4 P�� � | �@{ �+ 8 ��j � � m�) � ��� �# � � �'  > �= � � @S P , �@3 � � � �� ` �
 � �=  
 \ E �# H � � p ��� �	   s � � � ` 	 j�n �# � B @g 0 4 � @Q P L �/ x �� � :�� �* � *��   � 2 7 �   g�z � L � �= 0 �
 ^�3 � � ��   �  = � ��* 0 � � @G � � �� ` h ��� �4 �
 & _ � D ' p t ��U p T �@6 P d n � 8  ��� � � f�{ `( � $ �* �/ � �@c � � ��k � �a `# � � � P �  �' � �$ p ��� �! � � ` � j�� �; 0   � 8 �@ P	 � ;�x  
�� �6 H s@N � \ ��L �  � & �� �$ h J��   , 
 � �� � �	 t ` ( � ` h	 v��  �?����������*�����OC�;�����I��5��7���o��?A����������?G����������ߊ���>�������� ����F�k�����$���C�{��������{��������F����Y�/������WA��������
�Ԑϰ��m��*5�3�d����4kRS��-]��*�*���c�SS��8JM]m��	'�/#k���hU�>����7��3\�pL�3-}�h����S�FiO��������.��'��_mW��.��r�98���98��Xfsp�9��[/4=j��z��_v�7�9����赩��g��wp�w�Ӵ����D�'ɿ!588N��qp�l���i��P2"��C��uUòج���P�ۡd=W��s=G;Cv�C_u]=u]=;9�=��s9���zr\���O�͑��W>5D��I���T��eZ:8FZ7pp���;�����P2,�ޡ�uw��:W�e?��C�O4u��i�m�M��M>�l%��l����Whď��#R���������
�Rk^�2/�-;�?p(�����~��Ã�|I��Ӯb~n�̟h�Y>�g��u�g}27�g����C�̟d���d�-���2k���3��c��}���b~���k�ҽ�l~�������O��s���b�i���]ݵd��!!���}�5�s�p���^��˫Z��
^�*�r���
��=�gH���.�����q�6�_�о�e� �+����烥}�k��ʆw�S����1}s�̃Р!|W?��}@p���@�{Pπ����6��3�{���!��y1�_`�^]y���%�u]���
�e������d��R:H��e���p`F*��]�ː�J<�O�r=�>�+���T,�˄gxa�.O�VR~�BOM�Ɖ�xy*�Q�bQ_�����Kڥ��T,�p5�eR���֐���_�:K#~#<�=tw����=K��&�ѐ��1��V��)�b[7�,k��MڈmXS{�籉��{9t�{��j�����ϑ��<ӔwN�?0
�S���T|6o���?@�Kd�r��1�΍"_O��(*p8��xZ>���w8(GSk��r�Q���ZG�������u��͞VW�ss�+!�Z�ow�gs�N$�>�l��M�@AE�[��[�j��`z��6���o�Rn�˕�`�&E���fO=���5�;Z\-PɖV��is����r6X|��z�-���5��bKI2Wl��2߿���f�"�%��Z���2�5��I^
���Ά��ul(������~JV���MBd��12Bw<�eܩ���ؾ	
a�ϸl�(F���#z'�n8���ٸ���oc����v��-��,��7 �[�p�m}7��}	�u>I��l���jP�����]���I���
d�i߰�M?���XT���:6�Bkc�)�.֛Bc�ShSl_
�,�X
�1�>�sm�^2�B��ІfC'^a(q��:Q�[��<~!Eu320�:�}�Z����9U
�����
P��4 �|�7�s�tW/�7�Mw=����,,�tᶛW�{u6�P	�ͦ��}g�IN{�j.ԪX.l,������p�+|��	S6��9Y��sa(zH��7��"�SUe_�~8���
,e/ת�졥{bn�/wE��.i��2l��/�Kc�?�-��u
��>�6T�2��q�	�#ƚp��m=������!hę>L.�@��q�C��d�����ɛ�K�#JW]�������1�b�d�-Ik�����m�v~�;�^�{&���AR��8˝�sa1��9���\TL#b:,�CtNu�� �������s���H��9�C\����H�Ur'w�`���_���}��䚫 b���s y֌��	��#�e�����8{h���p��{��8.0��8(n��!w7v��"�3�?��7�I?��m٘=��aH>諠s��P���������/q
�aQd�yv`N���n��<C?f�N@����%���r���_F�ZI�Oj���_���#�#�#�#�#�#�	�5��:M��4��b��&�T��Q1�G��M����^��L�#�#��?��?��?�5��׋�.7��&!�S3��ya���n�Y��?�����!��EܩR����a��u�s5���oc�:��<l	α�D�5�&�Ӄ;���b�L��j��_6Xg.���fm|��ڠ�ԥ���d{�i�A������̫��J���NUk���~�þyY*B���a���Ql�D/ᛷ駱
`����X����}c���`K�����a(W�bsq�W�wcL�}&4K<�*:�B��6i gC�&�j����� � %�GS�>!o����-�����o.Nаܸ��
C�3�7lꗾw��[�WN�����~�x�f��
���)/*4͟o����"k!)�xV�i��1x����^x����'
�h7�����)W{�����յ��?��Z^^��c���(4��eJ���rA�LPRXH�n�ܽ��7��vn������.��|��t7��3x^�܌�EAxi���(�$o�C�\��v�J�nTݤ������GO�xve0.7��G�ܮ��}���o��mx~���:����*:J=j@;vx�x�m��+��`����SM���V
ϰ�{3C)7�>C\�y]�m(eV�P e�,�Tt�x�T� ��� {��C�^
-�����9)(ݙ"�lB�z��{A����܋����'��o,�H�B?_��B�}R�'ݞ��W�<N��D~Q!��A�_�_�e	T]Yy��������O�զ"K�b��RRR��i-i��� ��,�F���wn�,[Z�F����4�h��hI`�7!�����R��p���jvbA�"�&��5'�d��vH������wRW���u���
}�1+��S`�B?�;���O]�.���~K�p��o%��01���iڟ�{�B���LW��~�-�x@u���D_����dN�/��/�Q��N�'�Ի����Uj�u�q���~�}�o�;�5���~�^֫ǟ�	/9����z}���oU�#����k�X������_�ġ?rx��m`S���|�����E+�HY�VF(������h*ZE���&4�mJ�*E'�P�F��
�!p	��O;��q�
���n;��ZLldR��竺ڒχ�P�e DǷ�����+�1Ty�}J�d(�ڲ�f/���B��xʔzH��@^r3���3Z�%�U7�f���a�l�q|�F�p���H�{P1�/^
s�P�K��E��;H�̻2Ϛ�C�� H!��K2G,�2��g����9�L�3'U��{p�&�4Uy�I-|�F'U�RMz-]�^�V���<6W����%U����[�O-�sf���K���,=ym����.?��󏩟�O)e&�����͘WBϧK�{hk#7��`M��d`�iѫ�� $�Xq������PRZ�,�gZ����:-�}�嫢��Q>�*`�AF&A�&�;Ll��ߩ���M�����Y��&w����I�NQyԖSt|���0%��VP�/�&[�:��P����G��-�N���������@V3��d��� ۍd:Ld�f�P� ��:>ȧ�<�W0�כ�r��\��Q��m~X`ݷp-=����'c�kW����g��Ka� 	��lE�fHG�����qe�X��� z����|�GI$!�x�X^��܈<;���抓/ C�����	��p���p���A{��~if��2�
�FS�sj#,.Z�w��coa�oS����,Q����t�5k��Zs���C[���Nf�i�E����m�j�v�r�������x
ɀ:�bo�w�`����
��(t��Oǡu�=��8a}��r+O-��a��s�(�^'�A��ZҦ���KZ���\!����>Bb�h��Z����=���yԁT�Gw8)�[@ؚ��n����@Ͻ�{v9�ۡ�g;5�bL6��{?��5QCMF�����[s��*�<�܍H츚��E�'�B
�0�:&�)U7�hRP����P�u
Q� �4Q��|3��@��{��[�Z�b��>�w�>e�}vf�9sJk �B!T��hB��6�j^��Oj�0e3p�lY��������s�^P�aM��_f\��ꭴ���4|�z�V��_c5�o��K�V�2l����e�L��L�z�L)6�Lp��(����z���jCs@���l(��i|H�zN�q^��LI���B�6�֤�@���q�o������?�S�B�7H�fԆ�P���e���!��ڲTU��&�������|�WZK������������ �m�oNp�����
�p,R�Ð>��~�$�=�������9�2�J#�l��]�Ð&L
f�(ω!5 ����#4t���IWL��$��TЖ�M�X
g�����@F�#��1�d� ht2�/`0r5+�vCQ�S
^$�ɣm��h+������I�`b��%@;���� ��ĥ:Lt7�R
���?o�4"�`�ŸA]fl��;:�dH�X�Vr	�(`zc��J�{��2���:�3�v���KG�"�w�(;�J�QgF�=�d'�2-��#���W1�KP�����~��M��������\0
�+
D ����GFۣ����<��_�mp^�ᢁ�b�� g4s
�|+0����>��� 3`"뙇�VIw`[I��F*}���6��0���M��<V�G`7Ve!�Y�f��-����b���ڴ����*xͺ�eC�XH��@��@G�y$�"Jl�n �<� d��jD� B�	%ʇE�0�t���zr�؄��}=�sHz�k?}6h�6h�6h�6h�6�MDO-�6��h�_�\z~t۔Yn��eH^�G1��MƇD%�Z�[�,��7�(�Hޫ�5{^����Ű������B�O��b�{}��Õn�%���_�J/����O+O9���aJ�ج��SPf��s�Hg�c�˶7�5.�L $m�->�o�*�ط}<g�nX�(:x�N�]�*������O'�%�B�/&��KzB���Tc��ޚ	��߹_��K&?���q��K�Vw��`l����=U^X��J)nz�<��ȏ�̺8�����P��l��ή9>���f�g����n�>m!�$q���_��Kp�񓋢nM,��wD�a�#�����&F�����!
����$mz�r��BE�g�=6=2�ƾ�gG�D�u�DS�GfpW7�$���4�t��쐸����`���6��I-��lR����B�������|̓/܈p�3�1��e���oF��>����@�Fg�	h��v��f�����ò�,MG�}�����mѝV��蹿�	�������}�3f˃jؐ�~��r��b�;�O3���q����/�Yxk�=T�P1_�ٝ$�������H>}�`��>�>&	�[�~�M��ᙾ�ۛ���+VyG�Hֻ�����G��E�Fn���&���7P����L�L&� C�|������K�rg>@4+l�g��_���
t{l�0���^O�h�?z/��4�`���3����L���+�쥑�K�E����^K�|�Hu՟+�4:�&1ya�T�B��h���O�]/�Pl������G"�wwu']9�x�ع�����^��ϵ��7��ة�+�xn��L��.�)�R"q�����#y�[���oy�W�SȷMF&h�zY:p4K�h��<L���q�/�#���4�QI?��i�'a�9yoܮ;�2%Ep4]�uE�
��}��gh����P��Qwr���x���Pt��.��z�'�|['�;y��t{y���t��8͟�J� ��z?�r��}8fe"��.���4~���{��߫�q���;�u(aj~�{������<�~��1�#��G�1�R���~	�g�0)�q�D}IyGҌ�v �9�Y�~���<����͟Ҭ·Mf�4v	�E�P�w��g���@1'׬�rޘ�H�h�~�`��^+�z A��N����<�]-j�
��뎸��M-I�;��T����D�(��I2аw��''���u�
7&��H��Lw7�p@��u?,[zz;w�ݗ�1M�n�vr�=�{�7���|�X��U�e�3�*��r�.|$��>�.7[*Z��f����p6<e6)礆S*Qi.Hz0���W�Ӝ�=�w"C�Y�.���ߌ��q��&H��L�lP'0�Z��Re�	ә !W�315f;JnP�}�XP��ɽ�~��e�۞]��KY���h��lS��Vӗ�:?u�*<'��L]D_��C�;��c<
ve��Ev����>}i�쌢�ǥY$z�-�8��g�;���cb�o="Jޖ��� f�a}�d��(�61���b�q����m�?��e2��Y*G'Wѵ��;E�R�p��e�ʒՐ�xW*�\�`3����]1�Y|�G��{�!��7j����v^_�2��;;��WT��gh�p��q�����f)/�=��Ȳ����U�Śp���?����/疽�a��(a�WU^׮w��}��d�u!�p�㞵���$L�������Hd����I�[+��X٦�d9K�iR�H��'u뗸����G��$a�sK~2;��TD�`���&m�i���U��A4~{��	!B��b��ŗh?f� ��&�=��r�eZ1����U)������"u�8����צn�<�_��O��5pAS��MLm[Y�7����)�ˇ�6��I�^���l]�T���|�er��>��rs��Υk���?�Ά�2*%����4�ӱ�3g�w,; ���˷���D���>jo]w���4n���M�4]@��}Ex,d�p�z�����|f��N�W�X����K'�ީ/D�(��hJ��#BZ��v����.φ&l ���`%N�/�J�*�͜��{	�}��Q%��~��A^�.NV��M�R���&G�]rb��#����?��DT^�����;�h�H�h���@Dy���~P����
^:��r�'Ϣ#
�@ԫm2���W��X�P��~ښ\_�R� ���"����fA8W��j*�QY�n�Xh����g��$������<B��j������c+ke8S�q��H�C,�?U��s�?�E�M�@�	L��p\�$�xf�>�e_!!�2�7n�!�b�<��KDv��,3�ؤ5�:p�)���|$��'E�̝�C�w�ͥ�c�����E�98��-��1�5wm!N'{dߧq8�*o��[g��[Wg��eE_qeb��ű�B�Y>1��а���*ba��cʮ�?��X,Mo���Zts��-L��	"��Ȅ����A'w�uu.s�/���'&�͏��*=k�U�O}�y��¹y��~���R��j��|�RP]����C�G�(e�j�<�V�V�r�G;O �q�V�w'�@��J��D��>|��S&c�{�����guF���'��
,�1А�����Dq��3߿.�ЧwI:��M���� ���Fߥ�����3����j;�x[�S�7M����=�������l��2�yԿ"�e�>�[�!^���7��2��Au���Mf�7�	6\v_����ٟ��g~����񑉧�Ũ|�}���ꕤG���L��3jZ�3��=���s;�w>p���h]��+D��J\_q@���?�ټ乼��r���g[�g^7V�s@[�g�MH�2}����U���]�^�����
�� n 8��=��;G�G����%��p�F4\9����g�+.H �����Q�{��;���Ӈ��ѡ��z@#���D���V���74��`�1�ڀ�V����}Ѓ@�a��m�m�m�m�m��_ 2�����+��7P8�(���_��>��a�>��{�(��Wo��P�Խt�A��J9u�u?6ۚ�4��{�2)��{툔���v��B��Gc��mu�˔�-�o{�+���)�h���d���A(�,
  T�{ ���s������q��K�o@��*'���w� 7��8 e���8P�Z�]���^=����58��8F��]p������qupw��;A9��@����p+JN ���q�%��̅��0��ϩ���R���.@�|��F]T��}*�P�Ѭ*W���t�>��(u�h�!�K�ַG���5A��*��?�y �5F�S���B���TBS�`4��'�`?���CּS`M�r��@�Ns}$�zN�-���F_�}=�/3
7`�����J�O��T�7�����v�z�H� �F?�F�O���S��i�sd�s�?ۏJ�}��~O��?ۋV���$E�?�O���A��w��E2����L3��hڧ~fjQ��o��:�>5�S_���o��C�~�/�}��l�y��ei�(�� ��r���
��c�����k�x��|y8������d(Di�2MB���Rֲ�KٷO��%ZlmhAɖ�I�"
e�B�l�x��>��������ޫ�q�s���Ͻ���9]��H�TH$b�Q#�"���ϱ�~R�/��F0��\�m��4�oB��CĚ\�����F����ʷ��~$
���!���!��!?�O(A�;����1���0�;dXc��w����_s�FHB��}x��!��k���}\T����o�5mL���ٴ�_�/z����_�����tkk�ǉ��F���N���C\LxF[&X�t�0�S,��7���x�_R���/����G����������߄P��9޳��\�3#n��N�F���x�w>l�=ƺa'GW3gW�����+�� ����������������������������Ϲ�1��4����y[!�pZ�@��9�sV�f�vN�kg��&�e���0��w� 2���Y۳&�fv�{;�s���Vf�b.Nb���B��T�L���w@L��8����..&��?�������}L��Z��ȵ����B��Rg���6���k8��v�0W�z���^7��e&�s�/iY���|���ua������������y4����5����7����iڟ���iڟ��_#�1I�/J|�l��^2T��S$/i�߂��o��U��uԯ�D2�-�$���RQWىG2J�A�O���~W��Z��6���t�0"B��B�
�T�� ghTY	K7&�5�/x�~�YE����i�h�ɜdc�5�.�<	<4�$B��y�B��Bx�1�I�������@�M �O�q' P�p���#233��4���<J7��i$��$z-\Ҍ
��AHT�n��\�
�#��*�PY�k�*�G�	%�/��x*���^��A��̱�r���F5�I�4�U�)T0K�$�t��݁�x��A����4a@z�U�ps�k:-��b�q�UUb�W��1��58d�ߪ���A$/9�pej (ܗ.�;�nL���pk*��S��!k�2���g�3ƙT��'N��J�k)�C�0��O�j�Ԋ j��T�~]�˰�̀����W�/���rT3\��b�Ԏ�Z�� ��������NWZYM�P.BK� ���`�M��d
�e�ü`� �&@S��a.x%<DB3 ����9a�f^U	˜A�������&RG'��e������A�� ��,p˪���N���������SK��� �Y�[A�@l��A4��?�=D�#�%A�$�6:�]F��	�@��ѫ�� v�� `�|<f+�ͅ��	fLX��%"��Z�.(�^-ゝT��'�A6`�y3H@�@����t�������hh�8��'`���(D8$n5'߃ �G�@C^�(,X9��}[W D��_#���*`
�c�[H�8"�ST4���p�aA�by�	��c�p��F��ѓ�95oJ�1�C � �!E,o�-�A���7ՠ�����
`���"}���Fɼ��̈́�O}�FA��J(�:�	����%�1�@�Af<'�(<�\,�`��\	��:��A?�`�����%�7<��l���p8Rx<��?�� A$�0m����/�	H��`1�\"Ȟdk�q�D.^ՕH��Ӫ�ٟH$Ǯz�/ r���7�EW�Q���B$e,/�'��hk�y5��۟l��i-�`y#��@�L���X��t��� 6�(.Yj�"0�=L3מ ���H<�Fك��+�~��c�
V�#��VK;�4��5���rv�I8��0~X�X�<L��������sm�8pcx�ܪ���R��1D�W�`�*����n�ug	ΠI0�t�)�L��@�u�ma�o��$�e,ٵfV6�d`{�1��V��`&�8�B�F� }��4��0���k,��L�������	 ˆ?��
���9�\O~Vi�B6E�J)���z5�x�&��G�)H -
�i�������/�c�a�"X�F����O*���m�ؠ����	z�oI$�
�>�hO��
*�	�T!��3����#hhU
�*�g<�p5D��QჇLA�LU#�ы�W.�U�?����q�X��ճ��&T~J.
�P!<@�4ʉ%�G���C��xSDP2h��mJ5hi1��J�p�����2V�p�)�X�
z��=vг]�q���j�w��|Ds[�z3��ຄr£�1e ���Tc�2��Fٽ�F ����Ih��3N0�̴�� ;������x��u�
M�yG6�fᷟ5�(s���[����ɾ̗Yϩj�<��N�7Ü=�pC�o1$��޷N_l�U6�"~�
E�˟Tю����\ oB["�l÷<E��o�p���gG\���9��{��\G�"����Cz����]Vk�j����D���h����-X-��gKR�atUO��g
l�}��T�%�o�0)��o+K\��ů�/�H{M�I$�[

D���~�?ˡ�������ͷ�:b�q�ɨ(���R���>����+ß�!����	��O����'�m�H��^q��V����otl���f�'�cͻ���=z"����e�_֤vx�p7��3�l��N��8:#�_�P`�p�@�}b>F���(���Բr<)}`T�R��۔C�)��,u��JE��zM;(��;�2v�o�{�oK&���6��M�8��>E��ج�So�Y� }j:IF��'���`���|�M���|��U��
��7��G���3F$�7��߼���@��y��)�2u�"�{7�����&���HPړ����n����"XJ��u�nu��_ľ-�7�2�v�u����TCT.p��4���7<��[ܡ�]�aOf�MR�p�̻4?��R�Pi�
M"�G�L=#�
g��n_�����z���e���Q�[��E//-�A�7�	6���'ϳ��Y�N�3\�":��K�|c�,��_1���^Ȑ����6����۩�`���.�����WJgH�{9�wdB�!�=xT]�!�h���N}P�5�YEC����ޢ��<ˬ�W޽:�H��t)����;��;?�h��+��|��,Xt���y�&O�X�%"�� g��Ӵ
כc�����hw~�:�(��މb����K?���Iѹ�o�vݣ���q�ڛ[�*���a��������V��ش$�n�I땠� ڗb�Z2�bv��)-,��������4�KP�r��"B�uw����i�>�j�{�H���Ș=�ũ�_��&���i�X\�gy4�>c-����H	ag���Z��̕��y�~��Ud��3�����Ǧg�ٹ�TK\,K��Fǹ|�EeT�-��y/m���f��fNy����mп���B}ȓGL�w�ߊ�+`zF�#zZ"MA22����7�XsA~פ�/�*I��OE�8ג�v����+��OO�q��Q�/���0����~�m�?�A�θ\%[d����C-���ɥ�_R�o�M��[���.Sb�u`.rZ:��T��/���:�����%�0ܖ�ݭ�����F)���~���ڕc��S��RFD;�S���������ѧ��B��M��k�&<�p�kdC54ӿ�s�Oo���-gߣ���=;T�R�*wWT���#)�>�d)r��-���kQrvC����:��C\��3,��?\,
wq1�i���7ɈO$����_�
�RjF�l��HB��fj��)�uX���'���u�ʡ��Q��o�Q�d���M�{���{Ow���]׾`�$�����2-�C�ʥ�R��K湥b
�-�ͫůl���D�!�^(n<�\zг��@c�*( [�D�\43�\����^	���R���8�W�e��ЉFM�)~��){}&/}L�+'����9��Sr42���~����r��s�#�gCT��;&�K	��>{wZ�x�Ղ5�?�Ν@ߺ���cߩݒs��Ieo�\��O���3Z�\���mI��.��ݐg��F$�v��[D#�HȻB".���Hƚ���.�땴��m�g��L��wF@���B%s�l���"�����f�1	��؟D�148�l=&��3{�$��.<�6�Z��������5y�+�����ORE��a�-{�Iw�Ҷ�9��X~w�ĉ|[��K�G��%&�λ�	�ت��� �䋫0f�b�n��}V"��v�7�e1�iغ"�a�S٘Kξ\�⎄�q[�.j;.�`A5�4}gwt��#�~��YĘb��cNC�o��J
?nWh{���8W�c�q��tEpʌ6��_N��S5/�T]�{��tQV�l��*�;�����R�أ=�q���m��F�m��[�5�44�R�.]�^`�?noPu�'qld���e�B���yדKI�z��I��i��2E:�2:�����~�����-M[�V3�LZ���yZab��{/��7���a��-tu��m�r��{��w��~���Ox?N̶��E�7l�<�͈��.����,��gz/���
5h�^E��OϦ��LT����+�w�B�� ªۚ���X�S�]��u���nP�6��Wlc�!�a�����ry�O�5̙���Ç��q=�/���ꚴ�W��eGNg=�j-ҿԶ`yz���qŘ���4yR6�y�5{�U��z}���qkt�Ԋ�w�b����ڋ����,$���y8�8�=ܖ��Uڳ���H��D���r��_U�!o���i���ώg��>,P?-R�#�!I�h�-
i��?�#�ˎ��7;=[I�P�᫠��i�C̶"���w�O��O|��h��{���nzۤ��r���S�,�,ͤ_v|.�J��^3�d�����mg�-��E�oO�Z_��*�z�k7+>��!�$qF2o�K���|�*��Iw�!Y�뼊Bt�D|�хU���ڤ�<s3������6��"<O�s�2��ݕ+�����f��rV��S��֎o´�;��M;��l������@�L��kg��éJ�97�?�n6r�2������Ŵ���0�����.��aȻ��yv�Ҽ]]A�x����|�+[w�z�6t|��$p�m�Y5OǜQ�
�SU��X�O�̕'�3f�k@�S�#qϹKm��>�=t��D��Ȍ^�G�v�n�~�e��ڕÜ'�;_�w׏��w}��5�v�P+�16��z�N���������h�!��}#���~�{�s�(/t�a?Ifoۻ[�.�&+1��F�7��,���[]�#U}��΁��yH���@Pv�1�>Z�!b����]�J!雴�2]Ү�|Ֆ:v`a;�is����6��n7�<Z1��=ѝNo)�7�"���u�_w�t���t2�=R����ͽ����4�4%ۺg����s�ϝ���_�r��YF1�4�6ɔ��Y�#��\�ݏ�^a����<����U0͏���ͽ��{86�2�X�93/��~`��
}�9��96�卣m�G�䵼~^���3Rb�r��>���y���|�Mu
�8S��v-�g�y�?p�%�5^��+N���+�Gp��ߵ�~�O�����
[��b�Z���|fct����I��}̡�LﹹM������S��u�=�u{�J'w����O�U=���[М��ݣdw�0���{�N|�{ ���s3�=��	o�3+��H�t���q۸ ^��3���
�U��>(��j�h��S�
/Zҷ��>1�8�U�ص@�c�"��X�D^G��ub쵉�by�-_�(��yǫt�*��m�
ڮN��)T<�®w�t��|yH}���g���;��-+��0�6&�/���Q�"��ʛ�^���Tz$;�xu糁���[:�5�RE�Ǆ��W�w�|��B�`J��^b2�4�����+k+�Ӥ���x��Y��	Σ����V�I$�����L��b
��C=Z���x�~#���W
�;4Sf�G�=ܩ������d���/&.�r�׮�����@�j�@[yth�[�F���U���n�)�o������S�Z-�>	�Z����A�5�4GT�v0�d	��%�xpM?������ĜܘrBY	7��=6�~�ʿSM <S*8���ŏ-�{�^�"+4�=�P6��k�ol6\y�^��)�w�f=����l�"��}�~=����s7�_d>��E���RT�5�K�<%�)1��)r����*��=�q�E�r��m�^ԇ ��VJ�љy�O�_��m��F�]]��~,S���rG6fnaw���B�7��|���a`
��Y��Φ�Go���ݒ���������M��Ԥi̘��)��4�-
C���K�Zg�4�/�<�c�{������	Q~��9n����n��][�.��_ml�ן��8��gc�w�xL�9=��80Ґp���5=�Q��:y�z<�I�إ�����Y��T�tF5(�i/MK�˨�[&r5�.�Їs9"t��ӊ[
9�iҰ�z�l.��Dua}東oU��g�C� >��n����?���宥b�E�ȇNg;�k_���E3�8�ygل��7��5T�L��|8U!����˦)�?������/X��
�@��f��f�y֓�4��T��?XbR�yƉN+u�m���F��xtmcϾ�mv�D6�5��3<��x�#�t;���G&N�1�����x��� ��V��\]���M{l
����t���K5;��k�"A���r/
�$�k��>��1i���`ZUV2T{�L�{z���D�@��sU�����⃼�Ν^ò{�P��>��� ��R�e�>2���PJ��yN<����
�0�A�����C#s�G����Y�}&=?Kq7�^��}�_��]��h.�Y���m43�Y��Gi�U_�{�:ݶo/����1MiY�����u3M����n��{������}��g��E��$�K�\�A�2�|@>�����۴Sb��4�+�&���Y����5Uv�O׹׺&�6l�z�.�^z�p�G奭I����*�Q��$ܗ�8�C�����4�z�F��A�r� ��-K���+��võdi�(��}�����g��oi�%=������87]� �S��ۚ)��N×�#�Tj�I_�<��IHz��	fK���w�����%��P��Q�'2g�zf�?!p����7��}���>�/�����D���T��
P�a2�u�~k�s��s�ܙ�ԛ�d�[;,X{,g���������m��D��E�3
e�$��O�G�b�=w爺�t�)���
��a]�*,��",�K
�����fb±��W��Y�7�I�_V�e���PB�gYzd�(���=�@�����2��+����YR�ԩ�q� �[eQ���+4ڟ���iڟ���iڟ��\������s�8
���Xz�Dz�}��p��_�7��v� ���PwT��Q�(zc}*���HE���	]�H�Õ��܄���QS�2ծ������j�J�ܰ���i�˕���txx`�����`��ч��Nx����X����{>��A��'H;��P����#/�[+��XV�7��o��F�����==��U�1_�{1�����*�Eſ��#t�At���p��U�ơn_�G̈́u�2�ڥ�__�{�l-���Q��R����ĩ�`�N��8S�S`�������&?��s=�il���I?�gV~�ar��+fZ�#'A��o�"�`�8����S߸�ܬEp���\����e�0���x@�$p�\I�<5���Q�x�6b����D��L�,��������*��r�<λ�}t�ho����i-۫ğ��Z_���;p�Z����$Ty[Gȓ���u3�@:f�'��JFȭ���a�-�ޭ��Qk!7���CX|�/^���o���-�J���x�kш<D`|-;l�3p���K�<t��N���b�y��}��*�!�W�:pڴ��ȉ>g[x>���N��Gq���5���6�{��E ��Ksz�= �8��d��/�&�xg|N�_��������x[�Wp�K��0��u����6�@����Ls���$��3MR@��O�NH{ ]�L<�1R�'w;��u���z�����z	L[+����V�W2���{�\~��q�k=�R��[L�@��h1�Iq��_�������ӂ��N����X����n�M*=�����0xN�:�M7swq����j���z'O�pz��sH�+Nou�u�O����w)��~�%�s j#a����?y�{<{�Tr�8�kOU�������TZ}�H~��h�巆�95E�A��]9ōrR����[ �[�v���W�CVI�Ix$�J�I~}dp�x4��ͺ������@�������%�8�(�G@����31��ũf�H���e%�o� �lIe��7����o%j���HM		R��������"1�����������v�ܞ��&�8�9��Q���zxo�,��⁒��e$��q�T&w5�~Ή���H��l����y�J���zӲ�T�R9�k�<?���[o$a�f�.�%B �I��� "[F�z���d�+�+trVi#Nޔ�tj�Rۖ�Qe�?|H����:蠃:���2p��/�w�����II"�R܀�M��$}��1�٫���˷�C;}ٱ��ٵ	q;m��yE�!hs"�i��$��\x�:��y�����/,[�|����.�	�S�� ��p�/��Wy[������c��˗'�>��Ɨ���
�h�g��C��>���!�ߖn��OI��3�w�nz�>#��4�ö�vd{�n��Jo�4�Ol��������rz��!').���5�3-)���g(=>'7^y퓔~���Ҵ��\ 556~�Q��	!�V���rU�p�]55u�!wM��±��\���Bېk{o��+��B�����`������H<A6Ȫ� ��#��\�_W_T9����B�섳���
v�C=�`WG��\a!O�1�{C=�a�	!�ږ ^8���>�a���5h��aM}�:d����
c���J��f�0��c��h���ST�A3��`��]Hc)�����5Ã���b4�_{���3��6�f�3<Y`�X��ѽo����uA�M�F��Ö�5��?�Y�+y�-k�hpP#��>��_�g�� ��g�5����A�se��ǫ ?���8����g���,���[*g�W+��F~��O>����f�6[��wA�\~ܚϝ�5�����r���=�|n¸�_?�)/7?����p����wk�QƳh��C�����+�����ן� �:�x��l���'nS|5�*c���մq���x4���w��I�jmp]��F8qd_i
�8��\�ݤj�TU0u$��
�m�M��+��`,h%�h�] "���s�G\��I�����������ww~�~�,�X81(C�)�r��s����
t���m��T�\�b�f�Zjc�+��(���G����-Е�C��~T|�ʀ����L%��ͣ��rd�h��S~���vjk�_��ՙ7����7�~7���̧��N<�/זC�������顿���%�=%�\	���u%�7@�a�S��*�X�//��E}zbQ��1*XT������j7:?��x����^*?�0_1'
�v���BI9��C!���Q(
��ζP���v�$e)�����I���1)ϛ�����p��^	�J���{4���p2)AU�pO5�4К��R",���P$��#(��$�/�E{�e-�-]�'�x�N-ֳ�_ޙ����d��#�����BCch�w��&�c��*ܾ��-���&\9��آ��<��cqġ�t���=��?.ݼ��iV~��Kk�~������:�~������wut��������	�RG�����yZG��L0�L0�JN��6q3y�X�=wW�I��7=��K���/	@�䢏��q��3 ��lQ�4u��
Hq�z����X�H�Ar=�,�Rǻ���37���=����2��@�����_��Ӡ��H}��q%yȓp��CrA%��!/����aBTUa�!�\_A�gDPN��3eX},����nҁ�,V�3�T�<�ω�Aw�i�8P��֮�b�k9�/���qp���7;�{��c �+��=���^VD7�πSH�ؚ�&�B��n'V�wo�J�[�O��i!}z��H�F�||�o�%�� ��7�B;���&��_�懿a!]!�cn'�����������iѽYT�aeTug��41��t�����La���sj��0�h���L,7��
���+5�9��N����ͣ�Z�B���5��Z�۔��2�p�3-(��w@
�U����S������ú���򨵱�G�e�D<����X����Z��^�w�Mط���q��B��Τ���ۑwG�.��pr'�v��K���c9���#%�䌬�^B��� �j�~����Ż#Y��v؛�w��0�J;C�D�W
��N\*!oD�'�P)E{�½=�hJۓ@��{ɯ��p�ԇ-?g�	��2dqA��"�Scq��XB�A5�a1�
��x��QlS��>;�&	~nE�UZŭ��t�qB(�
m�8�uyiS�l�y�qH�G��iP�O�[�*��~P�6u�4UЩ5	%��-�eE]�ҩ���ڒ�������s�	�QM����s�9��s�=~λ��B���
F�"T�U�kʕ��jd�OZF�桅�͜��K��5�ך��V��gg|���Vo\��
=�.W��X�g`zSLoj]6>�ec����b�����cec5�O��"t���mo����X]�ep�W���&�����Z�b��|��5-���V@|1ݢ���U�=���Kj���B����m��˖�a�e�gwN]��DR�{��o6�~��&մ���\�߿ ?� �[`�]��^����j�Uٲ����B4�L�a� ��P�.�\��I2Ěmg��w+�>�d#�f?��~�֞H�?&��ߏ�ݽ�"�wB~_k��#
t8c���A�z5
��:��*Ӫt�F�'6�}��t:3�Q[n�*n�Om)��G��]�Ծ���K��5�뿫{1���P��e���gN����4�C�Q�Ok��:zB�����5|���Y
��C��^"?���P��"��W����i�I��~�_�a�oF���1����$U�kt��4mM>�M!��,$��p���~
�-R�$?�o�sP�6Ic>)-$c�&�?8I#B�>��p�Wv'N�;�ѺR�j�|)�����y��z�M�^�R_��9q�a��8Zh6�F�u��?EU�˞�^���pX:��#�U�1���ƖjRo��jRjq����wЁ�:�4#,���5>���ω��nl1�7 E27QAK�1[EZ��A}��hLam�B�͖����"��a�Z'�1j�U���L�<M��Rwj�R���ݧ��#J�=E��}聢��*��n�\���o������E}Ŵ@6)���)i.�Ĭ,R�v�/\�s�s�x3WӅ�z�c�V^nJ�WWL+�.��R�
}�/��Z�u��v�ށ�ėÍ�j�=oƞ��l��su7��z��p��������5C�޿*��3!�xg�G��6X�qC�bn���� 9�Ar��� �7�,D�g�>��WVς��E�PH9_K@=/�9���]��#d�zFm�uT��0�zf��х��)�3qC윙z���5��xv��b���X+�&+���e�ٔ�W�|��3ǿ�ɿkPϕ�ߠFA�uu?����XL�D��7�+����.gU��<��p���8���3��b`rn��wvb]�ٱ�7��G�bT��"��?h	?Ȣ�p�tDNz���V>�[#�C�ᓞ�uF#1���.g4��wuD�(���hehGo��;
_~=�sf�/�J�G�t�����w���1��f�y��[~�#�k���4Tq���-��+�����s�{���U-�gA�
Y�󯟾f��?�v��O�t�����n�X�vf������r��ݧ7�}�n�������밞�z���2��G�붸�Xq��3/���o�(�������i��c��r�;^\_.�^�^�^�^�^�^�^�^���F�_�G/o>0]P<;zÊ�����_|�{?V�����'/���#��]K�����Gw������������
��_i�m���f����?=����[�ϒ&��c����:Xv�W;�W�t��ُ��qt����1u�����:�ߩ�/���i	Z�g����f���K>�|����'g.����5�}nK���������?׼��W�Ӗm���曠������)���Cy���ߺ�Z��������v���{�x�T;���[��?�`�����Ȼ�>3�>]�[2�=�8�{��7��Ƈ��c>[h)?��z�z�z�z�z�z���Rw��c�&�[\��a��)	�p;p\��.�-h�Cs�-p����
4�Ap�C~!��+)���^ux�@�������
8���t�0\������k7~�๋^�G@W������/�'�d��B��+�����h�������7x�l'�4�|xm]�>�8�;���ėʁ��+�����h���������1����1{�⳩:�kw�����/���G�����^��#�����y�0~5��x��{
���kw�N~����<4p�g��Zvw����rJ��7
�٧����/�]�W�#^�V�g��<t�_��x���p��k�B�-��s�^��x�}�c=^��xe-��֗���"��+�?�;p�C~���R�Tix���	4��vฐ:��]@'����'������ 8�!���G՝����������	4�����/�/�h��p�'�����	4�a�����ɫb����:��.VZ=:�>�8�S�_�O���uO����+�h�������7x�l'�4�|T�<:�>�8�;����*���9�'�����	4������e�W�1����1W�=�ʦ���xR��G����_zD5X��K�A��n����<�$�_����<K��{
����
����}�Rw�<h�����[*�:���?�Sz�z��p �}���!��=���ʮ���J�V�g�Wy谿
/��v���
qj�<�����*��)�?�p��_�_��l��p�u:<�)탿3��p:|�)k	�촮�<��-NY�9܁�����T�%�xą���4��v�;��]@G����G������ 8�!���G���tw�G��s�t
y��A��<K�=����'�t_	�n�
��������(rx���co��������>/r�@߷�����9\��[���@�c�4��~���y �Cz���?=
�@߿��z>0�����|(�}�D?�z>����	��G=
�@�/��w��!P��~1���#���&�@�o��ہ�M(���
���=���}�D���@V�����C}?h���W�<��8Є��� �y<��q�	4���A��=��	4��~5���'��/�&�@����7z�4��~/���!����O���=��zb��E�{���$�S>�/��R�]���E�z��4 O����gO�Ȟ�ހ���)ٓ�<�{�����a=)�S����)֓<�#��!��=�S=/:?�S��'{ʇ���!�]����!<��{�����e=9��z^t���|lO�ނ���)ۓ�z�����=�{rhO��^t���|`O���]�S~����TË��)?�S�y���E�{�����?x�����=���"^t�O�<���"^t�O�<M��[x������=M(��[x������=M@��x��<�'�4ay�?�E�C�T���������)?�ӄ������)?��ꩾ�]��S�O���*^t�O�<MО�{x��<��{��=����
s5��
6T ��NH6� l� �
 �	Ɇ�
�	׆�
��	�JX�-�	�P�
��(04�*�aD'�J�74!*�aD'�J�74�*�bD|0T��Єk���]��PC��Ft�C M�
|� ���D������KyIQ��dHT�/����^W"����RpQ:L��Ke�ՃK��S%��h ��
.R��H�(;),��O��/i ��
�H��Qt>`���H)�6�����)�"�F��h���"d���(:-R~X� ��_E�;F�?����|�H���&�H��Qt�]���HJ���(:�.R�[�	(R�q�)?1҄)�8�·���i����E��Eʏ�4!F�����"��E�@#�WG�����/#M����|�H���&�H��Qt�a���Hz���(:�0R�_���J�~<U	H�ʣ߯�"�����V�}!���`�R��C��v��PE��Te������2�(e�}��9�*<��*,��K������J�[�H��D�Њ���JE[O���*ڏ�e�h���V�~D���Q*گ�"W�N%�v��bۋ�!*���?GE�eT�@��T������X*r���[�D��R�~,9hE��T���h?�����~*���T�HEP���*�lZ����hVe �6/}�Y��OUx���|KE�?Ue��:/m!z���('�}�N%��r"(}���b��h���8ȦUѠ�O��ۼ�b�h��J�~H�OTфU��c����*ڟ��	����*���T�?NEbE�_U���h��&Њ�W�D��T��KM���V��謁��*��+�߫��PE��T4�W��W%z�����i^q��vQ����K���C�����C��C�gDմ�'�զ\�Ev�{]/��jT���QA/����XË�B��>܃����ie��
��*�R9뱎��G���fC����)�֍c��Os{��6�k��~��v����Q۶�{��ۀ���ur�v{H�n{�8l���V~/���o�[X�^ý}?��|�v� ��W��;'h�7���Hs/j��
�ӗ��K^p�J��
?����	��~�O�-5|�;]s�U?]]�c��f���s�k��֯�t��uk/�l�%��]vӺ�����D��������o��7�}�-��"koz��Ｕ;���;v�?�{�^El���;�lon���������[{�����w��瑱��}7m��.kw޲m������v�M�3%kw������;�n�u���M������n�u�ޙ�)uM�w97�?�E��u	�֏�U�J���C~�I����h�R����������m[���|�vc��0ܶL�9>I=r)b�����������_S��2����'�_߯��v���՟y^pD�����ρ���
z�-���������qt�'���r�U�[������u�9��o[s�iڜ����x�?���5���M�-�㶖�<K�&��0/�=]2����GϚ[�����>t�C�wnZUG�A3���E���ڵ��}��O��?��ʺ�+��y��W�l�j|M�������/�M�~}����f��e?��������l���̑yz���fホnk2�tO{~zu3�L����&�q��S/�T�G�x���o~��>��s4=/�[���ǝ�橧���?�����0fV�yͻ��8s�O?>�c~�?�xsZ��ǚyor�͇�=4���s3������ܿn��r���m�����T�p�Z��������h�f�W\�����x~qqz��5�Z1�_�/웛�{��<{��f����Yp��ۣ��W�������l�D��ǥ>�p��$�w5��ֿi��G/i�>4Zxt��u�=����J��������#g���7���	M���/��-�;'w�;s����H{���k�1���Q�ā�X�wDl�G;�ʖ8����SM�<����ц�=o9yt����Q���O�Z��s��[jG��{�H'��i��:^nv�΃���r������4>0�aW��=���:w����N_���~�����������5�i��S�&���-u+37�]V�cf��?7�P}C��̵oN=���������QP�:ܑ����j��c�c��'�;.]r�)���S�莫��`su��;�r��pǥ��j��~}�<9m���`�3��yvќv็g]��J�S;43��Z���8Y��(�=��R{M��V+����WZ�=���K�����߿hپ�y���y�*��y~�]�2k��5��ܡ�4�����^��>ߑw��TMι5?�7����d��o�z�����V+���;�Gb�����F���l��7��s��|��_
�k��������_��Fg��Ɨ���4W����m�ζ��?\\�4~j󃵷�V�nM}��z2�}��͍�/%�-���������?��<�eM�����Y�
h�`n����2�Si�F�v�y�I���l����]��!%�>�J�C~�i�,�_���A��n���R�|,ƯF��;��vO=�K�]����_��$u� σ
h��n����B�
�j�<�����*��*�?�p��_�_��l��p��:<�*탿3��:|�*k	�촶�<��-VY�9܁������kx�U�gX@W���ǅ��/�t���
8�s��
8��zt��n����B�
8��yt�`n����2�}i�F�v�y�^���l����]��!y�>�K�C~�~�,�_���A��n���|�|*�_��kw�%x�z�絻'�t_��n�
���n����B�
����}%��x4h����-Q��������Uo~��OGU��_1�.��G�� �*�y谿
/�J;��� �����6[�2��F�O�J��/�z8�_��Z<;m,;�ExKT�w������D_6�Mw��:<�ځ>�\�_���}h�Cs�p����
�٧�1���/�]�W�#F�V�g��<t�_�����p��k�B�-��s�F���}�c=F��e-��֔���"��(�?�;p�C~��b���4	<�B��n� �p;p\Y�t 
�r��������n�B~~
��_��
����}%��x4h����-A��������To~��OT��_!�.��G�� �*y谿
/	J;��� �����6[�2��F�O	J��/�z8�_	�Z<;m(;�ExKP�w���|��Gy/�Cj�}=C��� �� ���@=�Rp�� �׮�C����療�/@�����@�#���� ��'��H z�
���=��P��D?oz�
.R��H�,;�)܋�O��/�i ��
`O�E��z��x
xO�E��z��x� <շ���=�{�P<շ���=�{��<���!x�O�i��Tċ���>��	�S�/:�S~��	�S�/:�S~��	�S}/�ރ���&\O�U��z��/x��=����
�	І�
��	�JX�-�	�P�
��(04�*�aD'�J�74!*�aD'�J�74�*�bD|0T��Єk���]��PC��Ft�C M�
|� ���D������KyIQ��dHT�/����^W"����RpQ:L��Ke�ՃK��S%��h ��
.R��H�(;),��O��/i ��
�H��Qt>`���H)�6�����)�"�F��h���"d���(:-R~X� ��_E�;F�?����|�H���&�H��Qt�]���HJ���(:�.R�[�	(R�q�)?1҄)�8�·���i����E��Eʏ�4!F�����"��E�@#�WG�����/#M����|�H���&�H��Qt�a���Hz���(:�0R�_���J�~<U	H�ʣ߯�"�����V�}!���`�R��C��v��PE��Te������2�(e�}���9�*<��*,��K������J�[�H��D�Њ���JE[O���*ڏ�e�h���V�~D���Q*گ�"W�N%�v��bۋ�!*���?GE�eT�@��T������X*r���[�D��R�~,9hE��T���h?�����~*���T�HEP���*�lZ����hVe �6/}�Y��OUx���|KE�?Ue��:/m!z��(�(G�}�N%��r"(}���b��h���8ȦUѠ�O��ۼ�b�h��J�~H�OTфU��c����*ڟ��	����*���T�?NEbE�_U���h��&Њ�W�D��T��KM���V��謁��*��+�߫��PE��T4�W��W%z�����i^q��vQ����K���C�����C��C�gDմ�'�զ\�Ev�{]/��jT���QA/����XË�B��>܃����ie��
��*�R9뱎��G���fC����)�֍c��Os{��6�k��~��v����Q۶�{��ۀ���ur�v{H�n{�8l���V~/���o�[X�^ý}?��|�v� ��W��;'h�7�U}��^��i���MRu^�6ڶb5����5ab7��^�Ȩ�Z3蛒��!v��}�mA��kF��'��=num���?ֵ[!��������k>�Z���gc��������Ih�-O{������՚m�mo�L��x��h�u��5����}��m���tX�w�E�_�ڒh�$��i���ˆ�ߙ���������{�o�����
C������u}�W9�����*����k}9����\�˥�MWq=����}ilSV�G�y��bՉ+�dtU��U]������g���2��.�'}����1'�/�?=ΘXz�	/<��%�-�\v�)+�9^�f��_��U���\��׼���]�3g�e�[�W���|�)�^t�g^��ju�r��s_z�N0?w�+^v��+�k7��g~��k_��N,{�����U'-}��Zs�+����D�:��DRQ�B�
�Dܜ��Ӹ^]��x}}^W��5|�/.~�>�����߬��s���o\\�R�ߴ�xW}�n�qxѩ�z���I�{�9c�r������ά��w..�9�0��&O|�Or��}ņ5/��7��o��y���ۛ��}���#�ʉ�^r�D5ﮜ8�CKG�>�l4q���%?0�&��8Qm�X]߻q·m�U�r���˛F7O���z3�/�����Omonڞn��ش=մ=մ}���K���]1q�ԏȘ:�f5��Ǽ����M��Ʀ��Gms�暶]�j���i��%�Xm5�k����n�����~ahkS���D�O��7�����?��h"�.��-�w^�����������"^Ǣ��`�$��8O���8���p'����*e|�.��󋻛�>�K�'�2�_�4�'�^�s��/u��ߺL�����|�&�|��_?��A��lЗ��^����}�����>Н.��ҟ��پg�޽3�w�p�/�֯=��uk/���󶭻��u�V�Y[_Y����3{f��C�^w�-k�߶�zY{�{o�����̞y׎={w��I[klώ�57��]7횑�7���o�u��73;�S�g
�s���|��E"�?�j��e�4>)w2�|��c����d��*/ :�K��v��(��b����g�s��|��N��,���]#�Z= '�><�}�h����
=]HG0�Yз�>z��?}�ё�%J�PuCQ�K���cBJ���tm �64��H{<��zԾ���+�DFT��������C�y2��K&,MKD�єaG��q�H�lI㱾�1�kjTJ'� 	G�ѫ��+|�]i����h�[�����&I���SkG~���L/� k�v���$�~*\��1�?X8��|^��.��d��וe�^�888888888�k���{ȍ\��[�%隘������~�,���B��g|�?m��<_cQ��.�e��Z��<���D�[�'�>���t���$�GD���>�+�RnX9)_]q˓K�#)����_/O^���XK{�����rt[�zN�����e�&�Dc#)d�D�!��&_}��8�uV�n�����'=��t����❅=�{��g+Bۙ�l�������~_�ǹ�O�F�<��(�'[wd�?���l�T����,#O���mbf�K�拾�1���".��b�Mc�5���1�������\zR���Ͽ#6��G�-�/�F�ys�ީӽ��\�nw�}ppppppppppppp� lr�'������i�7GA���4t�4��|�,�i��̿���|7F�¦�
q?snE�w��{�i�k��;��o��������_ڹu���Z�-Ng�K<g�6��Rc�Rx���v�F�t�lɓ����^�W��������������aJ�隿&|�|��� ���a=l~�,�s�LNA��?�	����9�_a�t
hu #�48\��k��yd��G۽�%O���K�
J�v�kT������	I����j��Ҡ�DRt4�ʱ��b���4Y�k(8N��*I�$ku����v�@��[+�%mP���!M���"FRO�F�P,�TCER_k��А�0�T��`N��yK9��;:��<'����F�9�~�g sP�By��O��f��ŜW�E�!��m0�i2:�)�0�g�5�9C����@��O�q.�<�<R��h��D�o��%���ήM>��~'3����Y�ی?�w2�^�a�����!/�Bc��:L�����~��|�1�Q�
8�r��S��??����x{Y������k�_Dε����?#8�-2��S>��4ה㽏���ì�����n����\[�/A�A6/���;��\Ww������owx��|	8������5c-F��e�e�2�<SC
Q�]v��E�������D������%��Dd-�K�d���1#�W����������{�k�~�}���s��s��9��9`L5���(6q��PH�@h�l���L� �&
�%P�ܨ?��L�b����L+s�sg��v��,9Ǌ����x��Yw��l6�+`&�&f��e�2I�3y
z&ǲ�-��\�q:*O�9�j&g�p#��E�sb�m��?�G����$�|��L��>��8L#k�����7c����=^�-{�D7�j��Տ k<�ݸ�)fK���qɥ<�S�a�#���iЙN�п�y���?����&�Y��<f�sPy�3�NL� ��dy�4<� �!4S�8K%6Y>Ɏ���_?�@�S ������IC9��r�X�9�������X�����s�rr�q���}��K�Ҁ���7��zKC�`w�@Љ�N��nN4O?�{���v�vp��vpw���0@F������������3��鼓����J
�')#e�j5ʔJ1\�JR��R%�B7l��R̕H���(�Y���Z�\��� �?Tٴ|$��9Ѭfɂx�#��l@Z�̗�rΆ_� =
6�d�XqǗ6
�P��g؈(��'��:��|l!>�R��G�Ԙ���5��3%P�j�Q��R�\�B�^(&�oT���8�/u@l�m��`��>L01@
�]0�$�k��p!�|�[��BD��K��F.��k��<T�(E�{�9(b-�?X���1/{p�O(�F�p��ԙ�A,��������d�"�x��թX ��%O��w�����G��ng:� A������Q�j�#�q�ۘ�{z!sz����ŘsS�6�+2���W�Tudד�z������M.� 3�%��0L�5��취E%L��5�}��-��J)���̴*���f�
����d>f��8�p?�
\ńHxg)O�H$1�DY�9"�q��0�&�F4 ��`*Q�L5[h��AXA
��1x�����A�(`��\9Hf0����Yax��D�_Q`^ Y F�M�L�S�� ;0J�N��Nȝ\�aĝ ��D|kb�7e�w���o�x�d�<D�B�;B Vfp�#���FʈV� b�L7"Vf��&�eP� �q�z�f�/<�-@�c�0��> �ЅPĈi�6Lx�|H���UC��EaJ��@��SbhC����T�����'t��
`-P�L�R�F.�`"��*�|���,Q��hՓ�V<(
ިt:����N|��h��)#��T��E<��Я�Ʊm	# ��=@���M��
���z[x�
w����ZP`%�	����Nj�Q���
e� �l�ۈ�w�e(.
��
�I�PcĈ�X��LaK�"X�����59Ȳ1�[(�Dk)@k��bZ� Z�Z'�Z2
�H>�	�.�� F샌p3?Ӑ9}6u��!�,f
�i���F�A��� �|�L�+��T@�7���B�Z'��K�m�){��	��� i��b3xY`��Tpj�Bb�b$V"hf�p V�t$T��@�@�S"�ءZ'�EU̧jU�P"�z � B����f��|2T���P�s���@�-E�8��8�C����+N�@�����ŧ��	S�1�˼�����Lk"�4�
���.���L��U�����%���px7�k�@�X2,Ȕb�� c��Ǚ�cA�1��(%�h+��������J����.�gƻ��w��ģ��cr�?ţ&�G������x�W<>���ct��b�5�ģ2�G�I<ޟ�c��?��-`�4�	w�8�^8��`'���v�_������* �XfHر�9ClM�&v�}��!�Furc	v+�2k�n\ ~7�����ξ��w�7��;�Y��Nt/}b%�R�/IQ���\�4�/W�\P<3B��>杭r
����oܭ���iW�x3��"�EVU��|~ӬڪyǥFC�?�UP��ͬ�3u�J�T|���sj�/�����+~�&�}���܋��;UC�t�4��ui���~�}Gi	sm��ؾ��յN���e��Y[�jU)�u�]����g=Q�
��ݚu9��C��$�cp�>z��.��t���J�!����[��L���|�1ks��zi�-��L}[���6�pf�U���0a��{���]�]_>�"A����\���$����mo�>ᖪ{���@Gu2���j{Z|BN�������u�QǛa���N{{���;AQ��K��Rn�z��g7OU����k�E2$q"/��)�ܞ$�l�Q"w֧}��ܜ=���w)�<��j��O]Rۘ�#���Eg��E�N�e����~��Fgj�my�Nǭ=$�{���qѕ�}O�����7
�.-0��U���F�9o��ꀦ	)]L�!�C�$"PQ�
yA%y�:��/	����嚱+}+d����.�^�_�%�Z(���xS����DF��lѷ㼖�ҽW�j����Ew7�]���$J��
Z%%�8ޟ8���O��,]c(xe�i�߅�E<�)�W�e[��65�J̵
�kºj��ٷ<pm�2l�#d�2��~�����
�Q��vg�z�'��r>Σ+.u��	�
<�xA�"ߒ/��P}4�y׋a>�,7�r���|?�}�Fշ�IUG�z]W	��C��;�[�x�m�I��E��.Y����L��/�{:���,H�Y��I��ݨĹ���s/�4�?� ��ϵ���o�K�h����d��~�]LhRb������P�c�H�PCG*��T�\o�:!�%+v��w[��VQ�|��KT�q�V��w��腽���Օ�9�ri�x-]I�1�n��Г{;�uv�#ii�n.;�y���*��k�:˽JʨA"�B4E���x�A�T^���B�F���y,������-���EE�:��.��^e�#��!-�#��铉�/�6��G���
>��9�rNN�Nʖ<����zs*�Jw5�b��ֶ�'=��)��&���u.h�|E�����C!���	^-���ϩ��ހ�.l1�{�8����u��ء��h�`^�cQo���=����7lQ���?$�
�|�\|���R}^a��W����S��u��R���ǟ�[�+�E;����Y�}��c9ɕ!�V߳��a+�tk��fۻ-d�Z��ԊE]\#�����U���6�?]�Z���A]���C.Ǐ��v4�
��UC
$��ch�kǠ�F�S���+[��������R����'w]��_ӹ`��e|�ד|����\dF���K��_�P��?n}��f�Gkr�ި0T+P�ccY��񌲍��̎�+k:۞�86L8Q��[�^�Q�r���O6�o�N3�U,�l����
ao]$��m_��.��/`r�^C���F�[���
ܷ?Ik�I�!�J�+?���(��j����Ҁ�wŝ��O��<T��cyc�OZ������PUz�+���ta����yE��7�o��R�/8�x��W�+4?
T-+��ڱ�XI��p܆�w�lI�~Կ�!Y�{θv�E��.k�5v//~2���ב�s��[\�
ߦ�l�+Ȟ����f�N��2�+�_g�NݙyOR�P]�CTUd/4�l^��R)ӻ&��b�/�'�z�FuwQ܅UM$��$S�V�-x��ԯ�j>ʼ	u.�߯�����<�����L\4:`�sq��ݪWUV����.���s3�#h�������я;�j��<�����m.���yI���UފO�g���[�x�§9~*�h���U<�"�a�y�������z�-��k�d�ʟ#h��.7|����D0�xU�����{���n+�$c��|�*B��z�Ҹ��Jy~���BU'�v���[��ڴi���t�X�H�71�Ȼ��ӑw.�����OF�x�g��F�RZ[�K�b����lB�C��Rs����z������
��N� .9�!N�(�'q��G��6�)��q�Ѽd�f�)��,��2Nh M`a�ÒQ���9|�!m���0�8�X.2��
}4��V�/�E�M���j=Sg�1�øD9ϓ�����Bלv,	���~x�Z�'������4B���$��{<����=��7�x(Ocsc����<BU����n�|����&��ʻ�ɧ�
x�����kaPܯ�Om��zoc���8���kV��r�o�ܲ���C��]��P�4��CD�Z�
���jj\�6��y�lA�͎뵸t��-��y�l�l���R�me�{��PX4�f��S˓p��e]3���~`�x5�iql��衰	MhL��w<��46faY� �����D͠�������T�(Cߣ��:z����3��f����?7����{�)]�/���i:�9���a=�JB���$$��P�k�g.�P�����Y&�c��vy�C3�}�xg�8��	���z~K�3Q�=d�+�H*yH�HJ}79��E���w����T
�Lǥj`᫖�2Q��F ��eY%��r� Fӻq�����Ab��߉ ��v$��`�(^����y�\�]ѝz
(4����K��E@�g���PT����X~$�k��W�P����k>)u�Ղx�������H��z[�j;9w	�G⛂X�'�F�Nn1I��+����BҮu)�ZV��g8$�n�[*O+�G�ev
���F�^�>�~^��mqvǷ��8�ҳ�]|\sK�7K�����ߒ2��|�zK<�q:%���O7۫of��b:��#��`AЃo[���˸�[�l=D�����c���E���Sq����6�>���-,��|гB��]������YgA�wZ>��V��9!��I9w��r�*�W:>MI?�j3o_��8ȁUZ�B����������bRe��
��P,ej^Y�e-.lGѣ��N�g��3�l�3n�֝��2���;ጋbi��vA�$��Ê���(��A����0��,�i��x�9�����)(���I�T��!)�����Pl�#�#�0d�p;���x6r���C_��S)Hr�ǻ;�݂�mv[��y�� �(Hn+4'������4ä��e.��V��=��f�q���s�@�d����(�I���V$*�aCEV���A��H<�b��8p]VF>��w'v�p�6X�T�	҃���!��9�����;ݎ~vG���A����N6r��{�6�t:�JD:hE�r��$Q���.W�L�s�T�>���>�����7�`��
T���`�� �Ee�bf��n1[�Mb$�9<5���bx�*���s�R�H][��4D,ǳ;�G�������O�_a��q���(O�������c]��8�6ˀH3r\��܏���˕��3r�����y��n�e�d>`#�R�)��\��y�X��X��5r+ƭ}�%u�5*�C��+�F_S�>���k�Ӆ��;AH�p|�4�Yb
�mj�/��ɷ͆�!
��{߸*�x?)l����qW{U*�A9i��f%(������{K`�����S{'��^ｐ��Gf_�ɵ�s1{�x���*{'-8��
��0�?FH�%b��q
��U�W�8��
�Cp|K�_q_x?����$ ��d�q�����N��;Xj�0��j�Ǫ 穱�R�9��*�n�,��n��
�Wl4V��E���L�y��J�'M���~n���2�j/p�-�X�"7W���e�qm��S�m��$�(��E�vuk~Ż�6{~0N���[����`g�������+�P�.�F��֪aJ�]�V$UY�#`E��$�n���@�W��	E�a
���o"'�p�b͐h�P�|���r�H=?q��q���$�o@0P;3�}��]e��:~4T��lɽ�U%%u�_-~<��aC>nq�[49�gW=�<��|�~�,����~�pN�w�y^������<��	���[�u��]��0�"˧�C����CK(zGO�Lc�G*+y�Z	c(�D,�Kޯ��2�ԝ��2�z�����;�cx��� ݔg�>'��-y[̂%S
o)��-vs#�a)�-��%��Z~���y���,+�#��QS�%��RK��Rj)ؒ�[�F�,��4���6[��b��\�S:$�<�W������
4��)�]7 My~9�||���Î� �����A�k�dYy~�[�M&�h��8M�2,y@�-M�A��u@��g�,\ش�&7�$$!	IHB���$$�
�*aU�PAH T9��q��
BEU�`Pn��Gpj��;{3罕/�P��>��3���μ�y���/u��81�h?"�Vw6�J�Kޜ
Ț��F�t];*�Lq>#�/�s�f~��g��^���M���F�"�k��Ŗ|��e�ɖog�vH����<�峓&w�����}(�Y>
vE�������W�~[>������4.��\l*��-4\Jۇ7��M�͚��@�������'�l{7���\B��P�	��U��?���W{]؞����w��|�p�r~��u�1t��П, ?Q@�ȿ����{ב�z�%h�Ctц�	�wߕ����[��^�+?� �o���@��cr�_d[Ɉq�
��E�q%S��B_���������;����}�#9��~J t<H2F�O��m4��*��8
#�h4����T 4zLד�C��	(�X��y`$���r61�at�HL�Q$|dB���a1�$"��Q�������\x-T/�AU����|���?4`��AW
�v�np�?2x��aT��7���m*+����O�M�m轵��u���\��5*e���W
�Dtљf�ڞ�w�}�)��*[!tB#g��x��<�tJ�iWts�lyD�8�x�$5/c���QM~H["z$������
׬���U�������E��b����3?�Ҿ�<��8�RCB�`"��*�x��c X�k�N8jI!��I�ԋx~��گ!�ͺo��XKaձ/��Vv���K{�v�c$�tx(�&���A<�<����M�u.��	wə��OkJ��?Gތ���^�B��h�/����s�����������tXJ�*�y�L����e��O��������H��O�X]�j'�ӛ� _+ϻ�Xp�ի~5��W����@�.um\� �I�>�
��~�_g]m��?B�_��Dpx��[p�������w�4�)��(=�2(�M!�m�d
1)w�	a�؇�|�܄�&��av�|-3m��ô=��^�i'cJH%�@ �!m&S'M��s�)\ѽ��]y���h�hG���>���?��������I�M,�h�1K��nUR|�_Rl�ó��C�53�S�/�-�,:���9˹�N��Cqwq�\og���\UYR�kM*_d*�3Q;�G��|[εnF~�nU�9�.1�\��#`gen�4����M�?���k�>��Ӿ�tej��Iͭ;��'�ǭ��A�
K�N��b>��2e(ϔ��ܪ[���:ܤ�_��?�����9n��#:\�N��p������v�B�P�*T�
�-�|��.��l8��^p 4�i����q<�酧8;�AH����I��} I_>m*�T�InɏZCr����x�ȿO���0��6G6��Or�
���rX)�Glq-95H�c���җM��3LqM���Z8p�p�U��Қ�����)�f��zM��ĎI�0<����R(�~�=
��E�S���	�]-�.����3�m߱@K�
)u7���W6�����|��+���#�S�� 5x�=Mg���l'�P����KM�߄�ܠ\P����S������|�
��ȫ�V���O�}����]���Z[X�zC?mbg����ݬA�]|��X׫L T8���Dt���$�X�!q*��0 G�Q�@�ap~\�l���L�B8���| Z��S�@p�z� ��ϰ���6�ي�XmfI&�}"��;�X�H0����6����b�syz��uB�CB��g쭃�|���.t�K+�+��o*�+b�;�vp=(��L�B�v�xP������0�φ�����"P�A�0��9���QTx�?�������r�������%�2�[�����o&/u}	 7����_�x�A�!��q�'O��Cfw.���v��@�%[�n�ׯ3�A�ms��̝���i��MaJ��8��w����懡���/����z��^eU�����,x�Ȳ.Nc����6���~��eq��Z% �SN���K_�\�#F�)lb��
�X�܍	$<��C� $���@"����؈�nHtCb�I�޹C-tW�*�Sq�*�⋪�"�WV�]ʺ/�<���!wϡ���Ҹ8�쎡���M2a�2l��ʁ��tz&t��]�mm���t{(�<:��\&_�i��D��^�̈́���o�sۭ�D� ��I�Xq���(O�80��G��ez5
�L�1<v������`�|Y��ӯ�P�yut�D��o-��آ��A��xᎏ�v|3��{��
U�B�;�"��d�������_7�pi��B�voW�?Z��F/�}|��@����]�}TQ��榗ڴ{����v6��AKw����g�]��4�}g��n��1��FQm���T��J�*���u��k���8-�+���V44|�SےL�R�D�s����o�|�߷`��1��V�g� ���S�d:���m����R팯u[Wj�V���j�W��TG��L�B^2�CEƧ\��uw���$��'����%��t���ۣm���x��59)1��t"��J)�����	�hS
���֭��_�]"�&�8��>�8�ƣ6/p<�Wфf����Nc��Z��0o4�]v�>Vg���Y�l�aj|����!C���9��i�@�w�op�r?���^�g2S�_��3��ǧ���������1���o[1�{���p]��~�����.����5ؗ~�C������(n���m����-Ծ4L<n0�}�h?��b���i�}dN9���e��߱�~'3wj��e����h�,c�í����E{��~~6����~m�s��2~��K����O�}+�/j��o��?����z���z��sn�uy>��������N(x��[{pT��w�w�w�D��Y�k'����(� ��M��Q���$�GI�4{#���I�w�(��Q�8C�����1
�l�1����H��"BP�=��w7wo�ۙN������w���s��������rMS:Y��)��R�b��"�͠�Χ��dm��4�����zvC��ver��V���&~ɍz��OL��gg�B"?äg!zT��g�t&�ݜ��\���'�2�J*��1\ z��I�B��Q��[2������k��C
���U�סTZ�:��c먚�h4
�!�
�5��	wK��KIN�p��͝��篖������<�[��D��D>�r���J�2Ϗ@1�����e�Z!��_��Co��[%�w���ǿ.�c�GZ)!�5��.���W����<�����_1�"����j1Q��	�_�:�5܃}(���l៣Pz�"6���"��ȿ�����+&��5�Q��c�z���Ľ��Qx_e�ĭ9X�s<>�B+�5����h��������X�ʷ��Yƽ�3�$!�b���	tok
��e�~1�[�V� [�,J������o�-��E��XM��N�f�I��] $*�x>��Y�g�S�!��n�R�H��N��_$�ʈ��n8A3t�]��X[wA�)@#P ?B51��o�{'E�!tI��@Y�&�J \*ɷ�b�=h6�Bq���˔�Z(�H�Xx��7��}ǌ��N��>-͆�u����C#��� �{:��B�r>�M�^x!��"}4tFGXt�sl:��/� �!��8��h�+�����.h1��[}�� �P�;+g�:�s�����7��i$�.��.ā��W5��0q	�ˇ�^�Q�*���3�8��'5\×����0q�= = %����Na
�ة�\n�OJ�Y[��)S�e�e��a'.K�˄��p��7�h_@�\��.��!Q�P��-Z���+m����~�$�:u�K��
��/)�$eO��~�r�
+�%�����_*(�;;εܠ|�{��ߎ�������*>W*��TN�y�B��J!�I� �j;nڄ����i�'�,��ZH�; r9�~N.ׁ��#�	?$��BB[r�!�-��!1_J�]!)�+s��PWϦm+C%��q?@V�
�2vI����ʻ��q@�ђ�M4th�&��\'$����e�)��-Q�Z�y�>�W�D9AqL��/+��Rр�7��!�
jJya�P�\��
@��>1l�w�
kue�:�z*��-���������-��o��"��ްw��Z<��1Fz�S����x-�(��ĝ&} �\�p�Jo}�Jozכ/)_h_�М5���_�װ�E�BQw�E�{�	-v�AP�
ۺi)��M�rm�0s��Q9�vd���伔����E��c'PՖӯa��>��i���s�V���[
�v����Ԝ͇�^�ǵ6.�7i-������R��Ep�x�'��8YaF��M�7pꞥ�{șK8�I+KY�R�����"����p2.�Ǜ�r��Ƹ���,���a�����Y��I�lN����zX���Q��N��ͱ���`�9��My�-�i����csSN��ea<9'륭.;������X��J1^K�����ncs:h;�q�Voη�����'��U?��T<���Yo�$�.�O�j����yŠ��n�W�:��,lɰ��_��������U���4c��ݿ������Nf���O���1'UU{W�����r�5�zjε��2��I��\	r����2��m[�/rJX��6�1k	�ﴕ���|�!�3ڜs��k��fg &�� ��S�2������3pڣR�C{�ho�
�П�	w���M񹤦ڧ�}����t�2�I�"i�S�wN���Hq��--��_X����X�a�]s����)�``�ԙ#����"��  ����f9��
�6��"�:*P��)��1���T�}��x}�)#���hC��v�6��!���AB���o�~o�9V�#T Z�i�4F�u���9*P%ǚ�P)a�"��U�ДV���56F���*\��8��˦q��G}^�x>cFW��Η���S�a1��?E�G��q=�m1�C�/���<d��f2't1}��&S�M���_6���L������I eӼ���(�������qӹy}0��a�I���������M�A_&7�˘xؤ����]#ׯSԤ���:g���UD?=L����$�7��&��~3Z�L��3�z��� ���H�Nf���2��¤?H��P�i�t�[_��ҙ~�~6E�k�_��N"��[�ϳ&��~��������g�W��K���Y� ߧF^��:º<��B}���/�N��x��[{|�������������&�\.	O!z.ɞ���8�.�J��wM ���5FSk+��E����b[S�*I	�	�J�Zl��F%��P0�o�f.{kN�C���_���|g������M�U:�Azt%�>�1�~���\d�{6�@�����oI�~��9)�*u2e"�����[�.��Q���xk%�m*���F�n�4��`�-�f�qу�i�J�UY;����׀.�;h�-#�%�_�.����LE���Y��i?RazEj�6HQ�s�*^Z=�p��N8�vH'�瞭�I*/KKW�Q�m)Kʶ��$;�2�K�̸�ь�{g��)z��:�!���I���+����ߙ��$�{�L�|��UpM��NN�06���|�eF��	�N��� �F�o!<1���Ä�3c�d�89>߻i��1B�ӹ��������t"g��ɇ����N�7�����@��
^��F�N�R�zX�+�U��
���W�σ
^��+x��Q�iH�
Q'��Bw�C@���w�y#B���A�E$��V:V��݌��Y����O<B��
a��^�F�G��4�?I��8��҅��a�+�J�kH������t*�U�$A!>�gr�(6y}�p����^������
IFqJy��T�cr}����k�Z�:���s�Uf���n6V����.q��\o���m6
��Y�S�J�S\� q�/�:��ޚ,Tt�S��y-/��]����n�tt�f�X��b;N� �	�ˁtq�:!t�)�OD�e��-�0#�&$Mⶥ@gCr��d4t@ݚu=�l[���/�]Km�+iz�<��֢:�q���e-�/�
~Z�U��/��a��ʅ�0��`P��
�T��,�%�e��y.�L�5�4�B�`}P���Ȳ���R�
�#���)���b r�7����<Nx\8"���k-�
6����R�zb��]�K�X��5�G����t��#�>^��D�^��R{ץ�"Q��(_��g%� ���j��j�-��9q
����
+��a(�\I�;&E�GPDv��ǔ���0���I����B�ku:������+�<�Dp��u�b��a�/_H8&�a�}��e�PuL

':+�M�K�3�)�y)���]���S6E�,1y�0e�-�	.mSJ���6�<@�֦��ϙU�?츀	��c/����a���Ǵ�1��+(��b�T{��HI�:&D�$?�bGn$�1v@��Q%���1���1�D9���#�(�<�B�.���� ��>����#�뉊N��a7VB�l�'�~�'�1��"��g�'��Z��$?��	%΃ޑ��� T�B�C8fE����8�h��8v����p�Ӥq���h��Y;U��|��DyZQr��@��c&�M��~yJ���#$ri����/ψ�vC��GA�\d4�%ed��D|��O � -��N�R%�4���b v�����ڣ;���1��g)��2b��s�"�U�1a
����Ia��'�D�!�����F�؍�x���#�	�;%'漖 ��*��0�A]�\��+�!Lm��BeK�QTzx�T�������B���#yhίS�[�p	�'�9�"�c(!
�g.��7
�~�D��9�z<&�!�WQ�ԙ;BB����*x,� �B��ρ=�7<��DF��8��0�d��!����V�m�u 6�����2��`��OU5c�=�(y;��eX�O�!��x=�U��xE�z:�wd���t��+�O���M<���\o-�q�E�I��]j��H�2��O}��R[�f��=p�O�=5���yS+�S-�>�6�g���s����g�7Ǻ��[ծO�;�O�S��};ź kj�/�F��	kWy�Q�JX^:�����}���!��7>��~=�[�ۂ��t#�5�N�Q#9�����
M𿴯{EF���g����˳�>�h]�����[��$N^VU��E�O�w"IU=�߻L���n��☀'�w�����\YJ���=Ȱ��lA��(�`eg��U	6�;�m���[����̽7�}G�s���qء��}���pC,���}[���b{%��d1,n'ʐה��Vr��8\� ��sJp���i��w�,��6X���6X챜
�Ñ`�u���킫���vUTܵ��ht��׹@�0�ps8��v1��흮f_��q5�o�oK�H(�y4
��32^Ѕ�>\�q�s�����͵;�H`��y^W(���W�����͍����G��08�l����	��?��h�|Q�e�}�d��?c�Z������s=������Q&����qv���k��Vj�d�/7�7�����Њi�A�+
���?��97ϼ\N�/3�=�n\��x��[\SW�/	_��Y>A��5�T���<jԴje�����Ih�k-`�NL�t�����s����3~f�v����]���lݝ�b�.���Zy{��}���~���/�s����9�{�M��wJ]e�eT22k\+����TuĻ�lc��\��H_3=5'r����R4u=�K�Z=��G�:6$r�^*�..��/�N�ڿX�g�z�To|u"?�&r�M��@��M���mL"Wcx?�2_�԰=@������+��Y�19�J�)pU�����P?��~��gi0���P��<�6�8ڮ^���L���V����O��T�B�Ȣ�w��Ч�#�Ϧ
����V�K�r�=����J�T��=�����s�s�
'6K�QBQБ^�Ʈ���$�
�*�iI�i���g�.����P�M;�J��?.ݭ�)�@�
۪����UW%�[���-�fa����O,�r����N
�`o�h����41��To����P�Y�2�[v蹔=������L��:�=��g�%W������'�l61�giy��%�k~ےgc�Eԋ5r8M�o�lV��J,/Ώ������^��#���F�D�,;�͖�Z�B�����BF�� !������P��'�}��~�o����G�~�
ۇ�n�����=d�w �Q.x�:|��k�<��2�LoЅ/TF�?���E$�\,��d��|��qe��
��|ɖϦ㸉�z��#|T�۬��?� ��{�ڷ��=|D`�Q� �3p1L��aX�ɖ��)$� �O2�E@�pu��a����~�<�Ʒ^���
�AKn��y��Ө�
����d_&X"�����A���
��s��ܿq0*�G�"� �E����C��XL�QH+�^K�>��Bh�7u�|B|��޻����m|�i�l��Ұ�BȔN���2D��q̫��,�2�wb��IKc�Cm0�Z`�а�J�&T	�]JNѷ��B�8�����m��<��IJ�p(��k�TJ�`yn�[*O��p�u�[}��-��H��p=�B���n�b=�$��v#��ǐ�6n���3b�8,$)���U�'�R�	C !�4X8���Vie��rB�˓/�N��k�Ö�R�G�Z�U�y�d�8Mgow�2�dC�|�����떹L�
�L�[,٘�{
f�L�y~D��n~����K(�C	��xj;����%)9��fě�����0����g�+�~Ç�va��� �o�v��W8��T����]$Ж��F��i�bf�㚥�Uh	��+Э�qȧ�P�@�	�����[+b�jr���BÃy��"XZ)�)�����Z�@���j�|tG}纎?���n}R؅~�Zyٗ*�ߋ�MT���X%�Q;��4��Jc����cU��n��C?�x�
�S���W+c[N��m�L�	.�0Ʉ��&r��1ḏ��^"�Ğ��h�_36�i�B���[�ΔlDɮ�l,'��d�Kn	}�+�A���;A��lњ��];���q¥��Xx�����(VV��*�HYe1 (��yA�����~�'�ƹv�����M3I��q
��H*����
_�sR�YK�j(�4��K�2��A�S,���~�3m�向L�ւ!��2�\�WHW(`�v���-+I�+.4V�v�U�괪qu�qu:Ը:I�ݸ�ƥ�P*ep����	\�ÕNZq��QZ)ƕ��ƕ0����U������J�U6%�4��A�'���ǜ'�p��g3[:�(��q��˥�azȂ�X̒�O�f%ǝ���>��ͥ�ۆ��QjW&�h��U�s�QX���F��U��W�x�Xd�e���Զ��<��V�ݽ��7�M�l�y2y8;O�_��qnx�?�:��%V���oo���Ê�� �	��=e�
���A��*O��j^����5�UM�*o�F_�:�A7T~���c5�j�ϡct�Q��������
MhM�����~{ړO�M�4��N��o�{�}�w��{,*1�4�C-�p-�N��e� 6�b�7����5S�!���^,g�Ս��l6�˩�<7�Z&���p�NO�{ds�)�}�l9�c�$���|��5w�Oƪ����u#Q�\��@�J�8i�v?�7Z|��l���DKb����F�."�
#+�F��ߑf��$ed���2~��sAve��8 ��jug'־��p�0�M�_|@F����2q�%0�
�RO�Aw�7O���ARA�?�f=Z�/J��'ſω�(
���0��p X\�Zy�1VB�n���<�V���I��� :����x�E]���<�?���7����Etu1�6����'�vЇ�$�D �^v�����x���?R|��_}�*a;炨GD���_����[�s�8��!�~����Wh{n��ՒĎ1��?S�ٓP�x�CB'���U�/�9�I����(�/c��a���$�Q >U��@�	��}���<�iD�j���%�4zZ���s��p���"�@�K�GN�.����ɟ��?��
k�@'%��h%z �r��_QJ|?p�� ��"��g�L(a��S]�R�y���_�-bBm�`���t��F�'��@+���Z�i�p2H)kU|-/���qFo�茄z%t&�BS0"�'\<Dѻ���	���v��P���p�8����O�۾�Wŷ�����f�<�� �PbN���)�z�B�%i�	�%�x�����'�n�.�'"#����"�Wp=��"����EC#$��q8�� $8�%�)1���'�>��}�S5l�?w��3�w���~��
��οw�h(�X���	B�xT�%{J�N�)���y��6�W�<9�K�z��[߆$�L<�
�'�֫�-/��nC�Aԉ�;3��GP��PO��?R�Hm
4@RG��XMF��NH.�����3}�P����]���gPQ�~�䭸=}�^��~
��h��FnTbf������O�@0�$G9�Q�r���7D3���~��'o�⡥3�'e]eY������:y���]��c�N���Y��n����s.�r�,����V;g�,�Z0筬�j��N�}'/p�Fx�j��6艕�8��8��j��(�p6���^��v�be�'�p��;Y�5��-�����f�U`i�Y���rY��rf;m,4co�,grPfk5ӌS�,��e�9xNp�ip�jr�cw^;�&�l��X��	.6��vX���x�8x�L�l���p�������	��LY�60����of�
�w4���������J���8�(�>��|�yEف�.@?�2j����)z��������V �-px@���w��������{n�kڬ��4y	�����p|ڎ_X���� ��S���$�E��m��=n�y�6��f�~`"?��� Sĳ"T�Z�E�YEQ�)/�ݭ�M<��S�� mЦ�?�xw�g�j(�c�����"�CpD���A�5��?��Z������!��㬽Ƿ�� +L}�-���M"���H|;m����y�ԙ[er���(G9�Q�r��&��hum��AC�ႆ����\���E�����6������|7�k{��IG���M6�i�x�I�&Z۾���M��i{ݦ����r�p�Aް
+q�V����ME�u��wC��W�U\������rUV��z�7�IH̀Ƅ�qфAH������uw�̒�?v���������������~��鞟�%E.UU���<�P��g������.h�Wq㜭�(��+��ߺ'�͗�2��y��y2�/�nOɻ\�d�i8zX���&��v��:�M7jӍ>41E��;�\v*XIr���J�W*s��n�����#�x��/�51wV܏��)|��e✒���q
����1�P��R�PUe�l�PY�R�U����ݩv-�Y�z�uÚ'*��լ+��� �RW�fC�����2��>/��T��R\�xᢲyy��K���>��x���������J_?�3
�����w�14���Y���G�Z�֓8����QTVwPK.�}�aj�x5�]
i��8���6r��D��ڋ�� ���B��+�]����9��Fc�1u¨ +PP�\h�N�zuj�p���SM]=+�.����lD��h�
��(��+�
6 v�3��^M\��9�Td�'i����H�:±#!=Jde25H�Bg�����5,�����E��;�QӁ������ 2�+��:�� �9<֦��\|
���Wo���6ҺzJ��H+�Oi�J�:�Z��@��Z5q��t�ŗgb	k���ħre�`�JW�G�k��J@��u�M���ڋٳa��W�6k2h�$����W��4�
��A�
�hl�6'W̉�����\=��H��b9�K@�Ad��6����¤���4��I��C���p��u�
�aA�ú��쎛��8Jή
7�d�r����P@v�l.V�uk�c9X�=����j:�շ[ng�����m��77w�bMq3�b'�z̺۠|��q���|�X�}.��8�H_c�I�st�̺+�]���^����=5�i7^
�tJG� �:SNZ}�[%��m2���rv����W����������C.>���Ca�0
t8k	�Z+LN��4�K��EM|,Q�(�"��8�"r��S��w}�:R 7��������ݠ؛�o�Q$'acx��Ȁ���X�
����p�!.:�u��bsO�� #M�h{��2)�����":Ӻ���d4E�] À��p`�qۃP��$��M�� ,

�{E\޸��'�U�܄�)x�����`�t�'c��K�6s�|b�ɐ�;���!�������b��4h�(��58`�M�aGD$�8�O:���q�@[Z�;�,3�ާ�b���TiX�DY���m��x���=�������hb����2�|����2�������🪢�,lf��.�[a����˰![�:���ְwk�|�v�
M7��ҍ�����m���/"��m��U��YO�������0��U��<�ߦ{��#�����D�}�r1��6?�2W�36�e��%w��-���z(xW�I�v�Z�z��w`�k�?�9����O�����N$^'�.*����Y`M�%�1�^�gd����αԦ����k�;U��ظ��%����b�ǧ��u�c��5,Z��j�������N�R-�ϫ��g<򽅖X{Wȗ~f��7��(?�ޢ)
�[���������M�YO��n��?��6"/�%p�
�8�+�D�@M�]o-пN������;�Hl��غ����L��O��M����>z��R�r��O�|*ʇ�TZf�O�s�~���"��,9���d���o�
�aa)��X,�1�lF�=֌"{�E�H3���PX6�r��;&<����4��@�BzRBwYR1~��z]���*����4D�A[rʯ�m;�\��?��3�B}bI�B�;�9�E��9p�4�iT��p�ٛP�N����_����h�u�
7Ȣ��Б���pj�T{ũR�5���ja�IW��ֿ�R"�j�+��)�׀E����L���`���gM��J3�ª�4����H�&�>��w��1R�xf�:��r��5��֐cMu,;����ͯ�j���)ׄ�F��DW��
�[��j�N�h'�5m*M��4���Ɔ���[�yJM��Tll��Z�s�����k��lEJ~5U���O�M_+~w���o��d�<�:;�+�w����M�n!rr'N :D��D�
��\i���O��4���T�JSi*M����5%�4Y��f�XJ���;�dy�����9��:�y�;fߗ]K�S�cםo�F�ηc��1��]�2���g۹���K��a�7f�����m�{M
}v
>��|μ������xM�>h�
��M8��q��+˃�J^UMYuC�����ʆ/kJ^E�����������V� ��4���~ݺ����\^[�])����諣��� ���n�C��'�0	��f�<\)���_S�OM�w��f��+e?:�2���R��v{o��?}bH�?���X��ߜ<_���N��5W������s�DI�M�${��v"��-~�B�㛘�|~�'?o���|��<u�,�~�w:�|�쫏浪z�~;��+���M?�&)���Z���7��O�����\
}8b�s]?'�lzG?�'c���M��e
}�M��5�_V&~�=�{"6�+��y��l����҃V^����z��;?���
�k���/���¯7�����O�gӧ�lĸ�I�Ӯb�l��+�~�/���Ix��\
�A�<m,��.8�Cw�h��N+���R�{w)����T-�����K�i?�T�������{�M��|�~�E�.J��
5�5Mk�=k��K(���>D�'!%]Y!�WL�6�O��KX�V�4@��!�_x m):3�R�I�ZM��9�X�� �@V0�A��B%w`�T�I�K�e�< =F��uUؤ�_"�./1�`��������i= a��k���5}���wU����	+��+r�O��Ud-����`��e$Hވ�g�Hg�R�rW2�)sd��|>C�_�,�W�7`.�>s��vH�Cbm'ւ��Pp>ǡ�=(|�kt�5NC|B��R�y�0����}+|������J����6C���CI.dr���$�Q"Y���.�6�����}J�:��.A�<H��	��s�m��
3�&-� �����}��a�:�� �-�=��W��ע�Dk��%[�z���u,�RDf�?�Ԓ9-7�ɵV�i�k����H�,L-i��LrS?�71�q,�^$o���]j�fy�Ƌ�/��I$-����h�[b�H�m!÷c��$�rm��}>^$|�7��:���>��e����=�����f��qr����Y��y7��1�=c�fZ�Q�-Fn�dj�"��n�!��nL�������Ŵ��y��k��Q���L:I����mF'��v�Mq|���7��]�X��w�AfP��b�`?LlԈ�rA�Ga�W���e�oDrA �L�h'9*�m";iY ~���9}sb~ָ!b�t�l? �3"��$Ok�7���F�*�(�� !�޺��M�H�D�~��=�d�D�&@F�f�����|+���evH�/	����'a<N�Z�{���N��}ۿ����E�^�h�HdG�l�V��[���YF�"��	�(�������#l��*�Q��؃0F�t�-��Z�(�ڽ˹x�o�mCӇ� ǜL��a�Ȟ�.(&��� ���K1� �"�6�s|{J�?�A�V$�"S� �kŞU S���
	N�[�v���+P�	k���';���@��gN$����'M| ѿ(���4 2�o 8&�.n &S@ɬ�Έ�'g�+T���h;R�EP��^hg}Od�2���>4�f �v��;Q#RH$'� ��Wn���"y��	YFR{�D��y����́�N${AdO�C"i`����&�cZ�a����5�l��_A&t�~�����1N��?J��(� p�l,̪�[�g�ȳ^����oC�u̀s�9 ߢ��Ȣ�4'���!�!������ �&��l f�j�C�GF�����I�����I{C�o�Q
���?ǶP�"�j眀H��j2���g�����P�ɜGt�'N�)����I��2J�c0r*
W/���x�!^aܸ��������bl!-� ��w�AE�����T���&�0N������zr�[�e`4����U���1
C�F#Uo4&".�9Ao-��X0�Y�y��DAB�BqR��M�1�����Q)�u�X�,��_v���Nj,`,xڂ�D�w*�"����7��M���f8�6c5 �r����D4.���B�h bH���8A�ѫ'F�81r�\<�ȷ_��F�@Xߨ�$�$��ŠC��1����3�5��0R��:*'�)'fM�	�F�.��-�cF�83�їh�Ǵ�bE�)T�92@ϑ97r��92r��E)z��?�'=�(/���B�j�*��n�^�Hd��z^���
�ؒ���=7z�c��^I����"~��)��1~Vߤ]�M�3v֢��o��<�fגq�п�� �&�tL�T�di��U��1A
��&ڑ3�uJ�T�d��^|3}��7x�eTt����xy�sԓv��t��p	L@P/�bbK��& �zԃ��v�\%�#"���J��W���M"�C]G�B3�/���qRG55��&�	�M��h��G�l��_b�;��X�~2�#���FFƕ��m~���*'^�?#@U��0��dO:����	��D�t��Q�c�l~T�l��}��ևel��\=p��;�����q+��ɜ�r��Te=U��dN�J���x
d"s�INRW�T�ܘ�A�rO���}�`��Q�{��)���<AEOdt��~��.��t�m�[� �m
?Q�<��X�n
g������� bINt���9��i��=��5�C0[S�,��7m4DSF�ii<ɘ�䯘\	"qE8�N���Y$�0/'�J��K^�nk�4O��*�")�W[���}�Uk����I�U����x��.�`X�#U�^��o+r�y�^|DLZ���Z�v��x.�,���Et���3
���$����Z�'�/�y�N�IZ���lJlg$�@Z*/EY���Bpf:���K�CR[���TBMڪ����֛V ����<AjQ��dM�jL�j�\59kU'�A����,�S�/�(�����e�ƛ�o�	5�Pk ����g�������*�R���
�������eB9� �ȡ�R'�����c�3�a��P��ʽ�܇��i���A6��`�Hޥnu��7��̊U�U��׍=?1l-��H�D�8�5)���&lx��F��T"���MwL90���2L-�T�D������O�A�������s�xaL9 �g	j�N�TLOW����v?=]�}z����t�oH�J��0�n�_��	e����<�Q̄�L��>�A9�ʈ���ZJӝ@ kU����pT-��^|J5��o��C.˻�~J4{ѻ���Q��"0DVL�N"�ȟ�l�(��;�+A��-.��n��[�Yy��n�� Êf��>�6����?_��'U��&`s&T
�9��Q"}Yph��m�B���`U;�!%�p	������P5��i.�(�nL��u:��b/ 
Sa*�5�������*�]��P��p��4�Sh�7W����
Sa*L����%�0Y^{w˕��EMh��������/���٢�7i�]-����+�W�5���%QMh�jq�/��ޭ�Y����	j��;�F}��N���L�n�P�-a������il�|S��z�����j����/:h����\%�HK�f����
OYY�K2y��y�d{Jʢ{�S
���A`0�+�+<垼����7����^����g�)��\)�^ayEI������K��N�new�*�k� �)��{���ey�<����UT����U\P>�3��=e��T��]���$��S �/[��p��Z.��mc����0�j<����pIk��-Ν��f�}����0��]{m?ܩ�m۟Z���/��w�{E���-�6����k��?-v&���n̡� |���?l�޾iq����#a�m�q�k�z��ca�m�q�|�a�+���{:ո���k�0��fϵ�r��?����#4v���"��d�ŜL��a���1g�x���U�k�{Of���
�晬�7��Z7�4vH��X��n�!������.�8����946���O�"-߼&4Na����3�v�.�&4~�����ғ�<g)Wx���k��E�n>���(�7���Ccq>����f��lHG��7��1�h�w8��$���'6�1mM�4�Zp��9Cz�m��^��͛�UG����G�q_�o��w����Q+ZQe��_�:�������7�,Kk��Y��.�$�"_5F�ߌ!/C�ey���1���1�<>_E�3�?�D��.�f*�^�Y��Z��L�"��&k�&���Sf2�Y�� �w�~�2�{0�xN�^�^��?I/�x֮+Y�)��y=���h}�ɓ�b�'/�,mQ�7�lŢ����+r�.���F/��V�`9�E/b:�}֓[��� ��ش.]y����L�eq��9P�5����ꢼ�roY�����|]��4/ǋ}攗��Hi�z����B�喌t^���y3<��rr�!z���L�EO�z��s�\�%�d��bj�)#+35�3�5�5+�I�p�69�<������+����x������j�"�e���i��b�q#��{w�D��	L_T�}9Y~���܏����KϿ����0{�� 7��r�A�� 7���ц7�y�An<';
B���kV�isٿ�-���~�E�/���5g���5j���]�g�wѓ��������@�'��e��L������-Ag&_�\�����D\��+�� d��
�8��J���(�>�쓕+Y= =F��u�;d�V&�,6�D5~_�_s����	� ���k���5�2��S�������ĕ⊕��O��U`/����d:o/�H̓}_���"UN+�
� �$ß��L�
(S� !�ߞ��?��W"��0|��u�Qh&�" C�~����w��V(,T+9$(��$\IMO�xܤ�`��� ���2��cU�c�i���#0"�r��PLZE�Si5����I��'���)Ҫ4DC� ���sG�1�?cI����AFS��[�w�w�58i�Ir��5�QH�)��br��
���L�o���[Q�P��@B�%��0(�F�D�oʁ8�U8/Q�	�j��(	W�	]��k#��e�@��o��>�>J8 �s66nU�ȳ�ȳ���~QhC�u̀3�9 �Т��(c��?D�Iܠ��o��AF�E�� 3yo��D�������_D��I����OO{C�o�Q
H�N8ǷP#�j�܀H3S5 MU#�3�
h�#�&w�0�p�?�6#E�wP��)TxĪ
��*��%
���F�Ɣ�<k(F!��2��`�G��k5TuScc��\$
�[3��7�� /$�6Mn�S��6ڌ� جc5���и\@ftu���!1�7&�	J�#1zF��
����$��$��ŠC4� `ȉ<��;�5
;��y�Du$�'�('���	�N�N��-e`F�3
їh�ϲ�bE��(T������9G��9G�Ƣ=�������Y�]�vh!�5z4j8o�^HHd�=F^������n�~{�ī��.�,�g�
�D>37�U�n�ܝ�ȟt܂'��P�a�
����3x��$^�h �#�@����.�bbK��F. �ԃ��v��%	C��WP���=�$���G]��f�O��㤞jjTPM����+�������p���^bm���T�TZc@Q�����Un�
F���Eq���?��[�&�b9
�!�G2���Q���f�%�W$X����Os
%�	�nk�I�)79I]XNPIsA�T��俫{��vã�8h�Slq�#x"CO�t��~��N��t�o�[� �m�h�h
l�,��%�$c�[�j�$H���:�F+lg�d�¼�\+Y/����y�L���D�J��A<	�_އ�iW�W�kħDO�:�ߒ��T�dZ�\�<=�p�VrNj��#b���K��h�}�g�erE&C��#���<�+
�ȫ�o�Ɠʟʽ��z')$-[�o�$6Jw&n&-����[�B�pQ�� �����cRW��m�TBMڪ��O�:_Z�r�Q��IR��ܧj��Ƥ�&�S�|M�ꄪʤG���/�d��Ͳ��9�T�/�b�M���ĚX9��^GMlTM|�\Y!W^J�pL�-/��Yu���������y�,WjM=���(����p��$UU�>`�=q����8p�[U������;���y����ɋ�J�K�Y�ۃ�ժ���{+�_���ɩ�7��O-��L�/;�Rh�M)���$��>a�VR�HE)�vU�����o>J��~>��N~�E��O&G#ѡثTz#?����S
��bj)��e�7�d|��Bm���ɇ������Ũ�>)RS0)��?)�u?)��>)�u>)]�ٲ/6Lz�P[��	m�
��<�Q���L�Dy�{݌����!M �WU���G�FH���TU�ګ�C.˷�4��tA�o�W?��o=�h	�`��29�E�e�ur$��]��@���LA(q���v�3+/q�-f�| {H���6���XDNf����r��{ ���Y �a�e��_E�e`Ƒ�OW1���"W2I��&��Ⱦ�R�L�u���:��2FT�㘖��d%�RL��<�,��6���^f8/�K"���e9fۃ�D�v�ɘf�|�Y�R-�`��I��{	V���,�M.P{YU�$J�䵬��U�W�����\�əh�oy�i�B�4��~��&�'E=�%*\�	3�o�39s~�w,�)'��>��zˤ�����SA��/���/�K29�9������.k~�3�^�s�n��>��j�&۰_�
�o����AUůĥ�Tu
��'�!Ƴqr/>j�*�=�Q�m��	�)�I]�7�6G�-�a{�F�f�C_���g:����֔ �����7�0Ɩ{�Z���Cs�-��T[�?"�6m�і�%R�ͫ�ʰ��-;��h�u�.�I�YE�� z�x+o�U]�sm�-fіPi�lK-.ږ "�fu��:���օ������lβY3�eL�۬8n���8����˒�Lx�>�O 9���#8n�X�l)�7a��׌Z��@�6�|������Z���R*��Dn�������&�v�8��x�o�3l۸��mևc��Rk�,p~ʰ���5���v�h�wY,�Q�=c�w��a<���0��x���KPY+����jX���;�����w���ı��ޤ�;\������W�n�������ZR�Ka�w�lb�u�<����cj�{W�w�Xٗ2���<6މa����
��\�o�
�WH� �og���?렿O�s�Z������i�e%��ޒ���g$
�3]ɮY��ߟ�<+/9)q�&�����[��y��Z�~�/�\y/�/a�{˴����ʋJևd<PV�_��M.�v+Wi��ǵ���
�K߳�*+����\������u��¼���ɕ�-)+�,za}κ�\H�FO��,�dݺ����j����0���Ga�
���$)%�'IiəY�%�K�N�R����&�;b&%;�&%9+˞���:�9�'4i9��*lY��d'���p����C?3(�Z�����?Y�61)cIr
����bi�2f;3rR�E9�Q�XO��4	�4mz�Ĩ;�&�ʽ��Q�5�YJ	���GE����L_?�YYO�__�����x�iBoX;�ͼg�0�:3�J����˾��ZM�:Ig�]���;ˇ���6���~��~p����p���פ*?���X��o������~�+��-~p�u����������4��`L���;�o��`9o)����r��;yq<oʂ�xC,�ʠ��֟�
���2#jz+�	j�`��P�JU��T�v���R���/T��M�F�f�N��C�+6����Lp���j/��Ҹ4� Qӫ��67:mO���ˤ�]#'���a���L�� F�1��0�q)N�|��(G�8T l�9a)"6aÎ���zd،��Xb{t�f�{��ـ��:�a��H�DY,@`3J��1e�ۙ�L����f�1�>�R�Pq��<��ʼ��	{
{���e$L����vL7s�ϡ?Pc�� �q������Npl&0뤙��ZTa�������W�x�A��(U5
ӊ�]�b}b&�|r���MG��ڛ&.���͔*�S���"�J�S$����B��hxtG %�x�#{4�b4����Ai��	�3D�X�Ĩ�\H�q��s1���3s�컱���a��Gظ�99��HF����4#O�>l�@��4��
�^�F�b�K<m��9A��R�-�9�%�`��S;�R�a��C�c��*���aѹ���k!��ً�~�����b�jE 
�˄�g���ġs6�;M����1��q6�W2jG
��N��T��m'S�Ă@.J'E�#�"Q.zD/+nY)�M�y�e$��G��*�\�&+{������Evh+#+� F�|����/���iD�+:��#1D(��HO
�@,-T���p�� ȖN�H��R�d��L�6�%I�/	MD��B����
����)��5��2�����#��jl�`qM0�
b����)�v4��TM��HB�:���8�a�a�x�V��^րіK�o�������:��v]mĝP�"@pK�6_�پ}6��EܴgP(":m�
��U�oZST�Ry���ߧ�u��?��sN���}�����w}�L{��	'oC	�/��U��cK��p���>��җ�3�}K�}_wѺ���o~y����q�}���м#�~�������w<�����Mk}��{^@	��ߒ���Ɖoݶ�²	y�t�L��k��B�-���ި��&|\?�=�ɯr�'���ʧ}%�^���ޫo��˞�4�sDs���ozi����^:��#�_��u	��[��]�)��"�h�eY�q~���^j�y5J�����A����~ �`�?oA��A��ͻn~,�t]�&�o8��N�?����G�/�`C	���^��ӏ��?\ue�ld?7���ޔ�z���T��ˎ����\��~����:|1]�2��c�?�
;��;��B��@W���	�iݣ�7��G
�/#��w���I�����R��CM��Ȇ�ߛK �o.�&
v���k��.��Y��!!q���V�]���λ ���������X�WCy%JYa�?�\z*�p�f
-�Jt��*����U�׽髄�{�W1�{�W��X���u��b
�ރJ�b>������g�?�m�|��*� �h����%ʉ��XZ��>�̢�u��Bˮ4�8�����੼R}a��w!v�G�s를��jIѺ�w�w�s��{R�4��$��8��c���$o5�P(N]����C�7�Z��|~����-�J�L'��w���
��j��s�B�R��\��x�Rh<�(4�W��U}�	]�G��U}�	]�G��U��@��9��A�Z�#~�&�/|�x�
PիQ�z�*@U_
R>�=�`�fɑ�r{F�##i6�NLr�.��Jv�F�h2�ݓ�,'+ui��ᖉ1���R02������+��=�w޹9N �n��b��^��Cb��;	�h���M"�8�l��zqt՜�z�B�����/�Z���gj�Fẑ��8�6��^��#�1�6S�\����{w����}�>��<}�}e(w4�h�Kͦ��ja��M3��B�"���W
���Y�3D�rl�һ��Z�<(F�_px�\�g�:����;٨ݧ
 M�#���q&/�D�/]��|��Z��R�KX��a-?M�qdڗ��$A[NjV2"j��m�Q�Y��n��3u<��Q9�E��dMTjFRZN�Ԥ�E9�5MT�Ӟ� �<{bi��(P����ؗ,I]�\�ylk�_�?���{�1���kW�����Ыi4�C0�ԼY��'�ѫ��z޷6`|��Jm_~��~+*�:>�<"@� ����/�ѫ�O�c5�˯&+o��j����S��O��� ��75�7�����ƾy�5�_���G����� z������S�篦� zu>Wsÿ��'��&#Q�����]���?@�9�on��o?5qz5>|'c~���?@����&��4}�B��=N�A諷>��?
௮��I,_�/�����	g�Wǟ�6q�o|���/�z������o��?���~��;8�;�����q|�x��=\TU�sgP'���e�f��X�F�i��(¹u'5�Ǫ"/C��1m�
~���W�π^���矆ȶ�?��:ٖ�:?�|cA�݆?%��/���e]�xP�֮ȹ�,������;D��o��՟^>i�ʽ�Iw�0�@]�[?q�膿�Ț�3��c�ܧ�
~B{�����^���W���o���"��^�"�\��U�� Uf,��/�oe���]z*�7<��ҽ��?=�+1��V/��l
�� �7���q�>R�g�o&�^��ǧ.�.������������xa�%~ArVrj�͞�5�2%ú8yV���d��sK|ҲD� 1#��X�N��OJ{$>%1=C�(y�-َYR�㪙�<�46��UI��$� �fϲ>�J�JNV`K2$ڱ�D�-$�*��@�Ԓ�]�g�dA����E�IH"C�?���H��iO�JN\a�FDb=	K���Da����F��Jc#ƫ����{o�����z�/]|�g\
���v
�(_{��#{�~��c�\�(���L��jj� J�מG�T�Ja
bV0��!OԂ���~�L��~�ZS+ o�Щ��	M��S/����)h 3_ی��(m%�QS)HP)V{
�*S�9@k�e�Tj��{E`k]��ٺ�pS������̧�T�Z��kB]�,MZ�@����ɅNۑ�'��ҩ`��1F@���>�$��᳌z =�}\����C�P
b �R�-7F"��@�:la��PO�F���8K@lm��lV#��k=A�#�=���(�֣d./3P&��	�I��MF���,�����OC���lLX���G)�jF�D=����cڸQ�?��o+ ��J�H]�pT�f�N�e��GP�"�&c3�����9Hw��@a���S��O�!@�Ol��W#��ׂT;S��ؼ��R��T��8��R������:� >B��	��0���nd��^�����(M(>*���m�3)4� ]��T�C'�u�Ĳ~���m%����kl\Ŝ��BP$=�{����{6�"�z��H�A/t�#k!�%�&�����h)7化q��%tc�YP;ESZa��B�������a�9�R6�|Pս���Q����
C��BW��t�:|�1
�o0��� �`}v��T62E��w �WP9͐m�T
޺ �	Ё����Ab[kӔwS7.�F|V��TŇ�3&PY���r�.�A�D�.ʑ�I�u[�Y�P"�}3k F J��t'E���M�o`������Bv��~���8x3�����5
�A+�n{��,��+q�*��ގM�Ԗ�l�3)���j:K�Ż�hDа�f�(D6���
��NK��t4��5R&e��d����.ɨU��{T�a�b(O�x*�FD�
�8�dk��� F;~�/m���|SRNd��hX�a���fx���� �(���@!/��	�+�ã�Ʉb>�a ��q�$i��ϋ�hE�%JŢ^^��I��!��\'�Ǉ��b��mUb�ڊ���.��O�{7�����~2Ѽ@�;�y �p���$��ES�(U跓�ґ���+!�V�'�j���^4�
���ӆ���ӓ��*�|����V��؝UC#1��w@�8�`1�ЊF����%Lu����?$pբ�ȵ�i�S��hP!���Xtp��#��Q��;~�
�P��=��p��^�m,�1z"�C� �f�:�ߌ� S*(�N�+%�\+u��amX*��ּ��[j0ڲ��5����2wVR�7Ю��M���JPn"��>���k!�h ��vJED�
�*zc8�߫�����y�6���t���%���ĥ���T����@^���M��������'�f��
�^�L�����﯎q��A�^M���}ΓA׷/�
����'��vx��@B�\��.��":[��8��+�����hh�wTRއ�T����Eǣ��n��b�D�������}o%4o�������x+���ʕ|G9�T���#/BT��s��-���/�O}�|��g�/���
0���
���Co�h y��p���YÎ7���3��s��+���ةF=V����	E(ˮT�j�e�+Ei�����`�"����E��F�C��蚯��ʴ'����Az�(����KN�Ύ-Z�σ�#���ƣ[�<���4x���̾�ʍ��u�{l
O��v�9퀗�* H������ii��0�bϒ��
T]�[rO�9o�A,fH#���H_�Nf����1�K��h"8���(3�S�K�I�Ċ+�!�%��w
<kӕU/A�Q�2�U/[�Q�V˵lE��
@Qo�P�s) E�J��W� ��S/�Ќ��=��>k��xX����##he���%�c)Ğfr���rc��[�
C&H�b曂�`��`���q��oI�,c�0��n�;���:݃����Q���a��\d��i"�
:�~M[92!������8������0o�ϼI_�pTv{�#ױ��3�󚹡�i�[K�A��{���݄/
�^��x�C×F����
rǜ��ژ�+���c�G��?�j�s��=�e���N�z�ǃ�	����S�8�C�=<R
�+�B�K̩%�D�ЬT3=�������Ӌ:�j��ӻ��A=���G�.Z]Z��@��A1 ��8�:ȶsW��X]�c�����9���<r���y�kzW\�.[�� ������>~�`Q�.:��?�~�?jz�C_�K}�/���ԗ�R_���<r꭮��z�����\��\��y*_�܍�ܻ콣U޷�_��P��rWk�\P�hM�/}U�N].�+�!r��
�eڶ�䧚b3��

j����=%g��qO�f��깣s^Y��?�iZ�8���k���B�H�<�yڧ���~\��ǹ��̟O��$>��Q~	�-�˝lB�g�If�n��o1�0�qE�`K���ҡd:$�X"�&�( 	�7n
���_�70���5 ��l�5�8�/7������
��b�:�];�a��`�b4�+���(��xd�˟)���G���_��6�?������#v>��ݥ^�k+nH<�U`�Ւ��.��*?`�5dN�������B�C��#s�8�1�	�Do�U����������+��"&�brU�:�W�b�O����%�'~�(\Qq]`P�t�`:^��C�2�8]�	�<�$�[�Р��<ȴ_�,�G���d
�
�>ˠc�3�	:C��;W���蠥+tF�h�VY�}/��wl��5K�*p���cbk���ԣ1��P��j�XV���W�1����ϳ;Bf�
.%s_Kh��=�|�{M�Cؐ�w�l��&�l��&���$�甖̞%���7.}<�x������J&5m;��蹣i���Sw5�7�À���<.hqtH�gJ����K�w�'��F���-�o�%?��^��J�s\>�t�N0؋�/���@�y����N��"�G'W�c��X~���u�ק`'}�pK
����;����u0E�ٱ��,�|��?�4�>>�)VV�r�2�O��RV��R�E?w��Q�u�6��,nN��TZU����<��+e��j���oU�W�Y#�9՚J'ӡ}DnI��P.����m:��z��#�TLM�
A�KF�!lHdz�Xn��ܢB&途�@��j8�9��&Cm�`k89]"rsZM��S��X3d�о�ն�H"�����Ŭ��;,q)�Û���#\���
*7�x�g�_��.Z�zv[T�X�~��U���szvP���ɞ����U�E�+C�l�h~����5O
��ո�cB��0I <}YF}��Dh8O�X�)r6�?�
�q}�GG��29wpcmҮ3��E�_����F��=[���}^�׮�+�v=���;�	&L�0a���8�wG~/y���ǧ��V���e�ʞ�w�}�pj[!4��sZ<e�(�d.iQ
�8{�'�:������;8s=)�e'��v+����U����л�I
��^��K]�;��=xʶ��T!�sysxR&�ʑ�	'
�+����	��HB�far?H��[nx��-ĸv�@�z�����ɫ��c��I�*��N�XU.��vh��Sw�#7���ڽWڽW�W�Z��iG��B�8)�/�FVS�\;��Η�����a<�l��R��l�_�_F��S��^�K|F.3��r<���K�� ���sj�>���!w�oUC��ߦ��i�]
6,��<��˭ks\Ph���ĩߺ��Ǹbg�Bl�2^�[�;�3'�qK~$����Y���&��=��m�i2�
3���N�6�ɜ�	�
cJIڔ���NB"t���&�vu0a	&L�0a��'	��g�4��p�(J�x�uUQȋ��?�O�o+
�daۆ���7�䞨*w���:����R����|�w� l��c|���5�=��}p���!�p���������;�ei�]Yk�~�&����%ޓ*���os��T�0m����w���.�_v���,ޕ�y�e�wI�S�xv�P�ߓ?�mao��;���Cc	&L�0a�O.�R2;;7m�)�W)W1Gz�����<i�=|��u%F�-*��t�Ԑ��[��Tn�2;+����]����Y�4!��D����2��=E-��:�Gˊ���_��i����Λ?r���?t���H<�H$c��]G�n���$z���]aOs����WBb�?�$gk��74"�C�H�J�
�t�%:�����˕\ɕ\ɕ\ɕ?F!�s։[q�^���H:l���-��p])�վ�� `
����߶}p�o?K��`_�_��/�������r�VL���[K�#�$q���mF�A{��$q �H)"݀8���^@*�ćH? �a@�"���1@ZI�� /��Ƨ7Z��=
��E�qB%�I��!���.E��U���nS1�ի�d���֯HKn�j�Dr�
/3A���������_
����׊�E!�oD��n'A�H��
!u�"�F̄ns�D�MD�Vz4��V�F`X���@'��w�~P���h�:§�C$��AH
����د� �h'Q��,L�	����HH�m �3��@OӧU��azTp�
���=%�A4��k��$:���H��,�9�܊:!}`��p���WN�;,���
̭؆�*&�a�H�$�%�Պ�.�/TX�).���X�!W�V'Vz	e�Sk�� �@ƧՇ�0 ���Ԫ4��ڈ,o��8t"UV20�.�����ӭ��	���e�S�;��w�OY��k�������kp���-��\��.�'a��'���~�E`�
�x�i��x���i�xbо�My^Ǉz�!K
����M���@t���P>Q}���F۱)�]��ɴ�[��o��_�%?�:
*;��wՊk��_7�Ʀ�*�i��f%���/��%�q�p}��C{�[��i��_�������}�K�$�3	
�g���Y?};Py���j:���ǥ���"�0M�%~p��,J�/Q�MQ��o���O��۩���)>[h?���r�l�#{�
�6t">`�!p4�/��_�MU��K���s�ˏ�k�S�!�|9�k�@G.Lxgd�hG���=��{�5Z��Џ�.�|?r�'�|�x��ē�F|>�#��XB@�������x���q
O*�f��c��� ���1�b珆UG�l@�ԡ����w&�N�T�"ˉ8Z��UP���
ǜw8�Pow��hH
s�Xa�]x:k��kd�3���T��
۔ m��Mkg�%L�	�P;V�x֠����6��,�dʹ-e�o��cm�VF7]o����y����V<k�7��d�>ӗd�S</�M�� 	�^�� �/�Gÿ�e;�Y���~�^δ�a���Њ;l�hC9�96�J�=���۾���5M�� 9��
,ߕ��Z��
�4�lW�9��m�,���3�m+�+����+I,�̊�x��X)g��6����Ÿ� ]9����kq}fy!o	�6���6_��@���μ�Z��X?&��n��r��_���j���Km�?�@�Y���06��mV�����9�r�a���9��o+�[6���=K�x�m���j�+��+��+��+����Ȭ,Vמ��4�?`P{gw)cd�f/si��j�sf�-c�%����4�k1A�ݲ2K�9J)"��nb�륙wڒ�=1���ў]���%�RC|fe�?��s�N
3���O����?1�袽W�G+>lZ���β�h$�"��U����=7��x=k�V�
y��{˝�z��q�XcL�J��gg�Oc��=��Zb�v�P������XS�%�^4�BAΣ�D�imV/��@��^�*��z�����<��`C4�;l����8O��ƠQ���v7��(��.�{w�E���eg9m6�_1䭖��<���GɈ���
��Z����\3�3���yR�-'����~�2R��xj�6��|570z�<��[4ҵ�i���}V1f�'?7�8{���{�cO|sf����o��Q�v^��I�?P���,Pe�/��w�3��W@N���I��I����0(ɧ��Y�\31�7����%���h�Ty�����H�#T��o���7g�OeC�ڮp�'�Fb�ttvw"�����"����X ��n����5�@�l��o����:7���j��3\W��׳�����#t��'�`����@�1��Ba߄���"�
�rL)�Z���B�\ӏ+�%
�I�\�^�Rȕ�|F!W>F�2�|T!���P�"�E(�����ٌd��gG��R":�����k�>{��Y�@�c�R_HN����������2KPë��
-��(�@ȾTL#���:�@�\H�l&E��
�L����hMm�x���[]+Y^h?�$Ԍ/��Z����p����@�2O}K1�zB���P�A�k]3��o���jQ���Fn����~'>$�Ǵ��7�x�J�;5	bJ�%��
x������M���9���ɾȅ�5��t��H{7�b6��4��11���B>Ე'xKe"f��aւ�g'`B�t��^�b�*0�$��x?�s���s0�l�'~G`FQ�b(p1G\̀�q�!˃+�p��L�3�}�,�X�Ь�x�O<�w@�z�.N��	G"d��v�[-^dq�]잫p]s3�n|����U7� �\@�H���w�q���D��|��ǀ��fκ�!�N�5 rW���fθ�Ǵ����`�4N
������E���|*V<p��m�3^�3�����L���z���>b%��(r�����@�o'��v@��R8ۓ��A���dƗ�#���<�ˁ�̆K�Ē>�����Y�_b"�-��BX3lä́��F�FB5: ������\|����8YcZ-��M��2;�-�����Á�o�p�~��]���>�1��Js� ?�5�GҙY|2(^=騺Pu��p�@U�����J9��U�UC<b?�����O�`����_3l��I�Y��31��?����`�#��bކ��$ps�Z���Kcp�:����8�iqL���#��a�-��;C;<#�ʤ�CBb�%�=S��^f�G�E����
yO�"�E(B���ш�V~e���XW�y�bsݼsC�نB��E
��xdD ~�(���R����x��+������6D��G����f(��2�f��6�w5F����i?�oA�ߺ�:��>�C�PO�>������&���9�����m2���4+��6�I]��zG	g�m���Kyc��f�T�q�j�UA�ɨ��P"�ǖK�(���5�vhxc�6��h��4F}���6Bo��дN5Vr��s�y.����i4��z��	�>��{ԇ���Q�}2�h��coK������i�%�M{;t���؋O፻�nf�d�S��S�E(B�P�"�E��A�P��Ϙ}��(���V��rc�&����<sg��!�+�b��#��Ϝ���f���|6l�/�*)�ϸ�@ϓ�g�z(!�����2�~�j|�Ĭr��)o+͍W^����������|���Y������j_$�����ܥK�v�:��Z_�\���o�1�kB�h0�ļk�umw�5��տ�;��+�c�lɓ�H�3ܝ�x�,yIEd���Z{Bٛum�X`=ܥs��H��y�5�tD�]O�����G��(E��]�> $�5Q���]]���w5\,�e�*�e|H�r\��A��K�YM��З���Ш�G�/0�1
}9�o��5�|��
�a{u|Ϧ�!W��A�w��W
���J?e��/1���	�/�G�;������ߥ��P��
�F��?J��d]������_�H}5Sx��}
�h��9�|�GW��ɟ�_��|��Re��o4�g�qg�X��;��`F&w���yv�@�>(�en�e~@e���B<}�L
/3����(��j��h}Ȫ��P�n�i1���R�K2勐%�%m�jG�r�Tf�͸*�r��x��)�P���z�a������R}�]p�*\�"w�;^-�*�ECN���H����F�;�IN��lc�6�� ��B����.��3e�Kp��2�u}�y��i7�
D�?�hc#b4� \>U��oS��[����/�/��o��s3�]-d���W�S�T�d�7eJ�' �z9��g#A�z�d�KY	x\�"{�%�ɧA�f\���[�^b �+�"zB�;���Ew�u'	�#�}A�ź���+���b�ҵ�|Yi�2�]	�J3dDq�T��y�A*+��>IS잮k��R��!Ϙ�!�X���"O�V�n5-�:chg�Wc*��e.��F�,���2��͌	��	�eZ��)w��H�|I�\�e:�˥Z��_��2{��9]�8�6S_&.��i����-F�{n��Ï��?������\�>����b9�:;fi8�����r.���2���"��E�b�����y�
�?��/���A��V���>��(�Z�Ï㰶0�?RQ�b����i���`��<K����4ɴ�e��%���8���7UR�V�9(�,*��i��Gк�ta�,i2 �0B�~����tB��>�z�z��cJ|
GPi�2�4��#5�[��d�z��n�(��8\J�[4
�p��ę�w��,�Α�J���푕�L9�e��f5nф�?:-3�G|d�[q�y��*�q���j1'੦�\1��v_�'�D��}��Z3+�3�_�<UdG��Jo�I�2����!OMb����VF1B�6dv�|`.-Ū.,��e��
�IbW�Y�H�i�")r4�x�rFV�/	�:�!Ŋ���F���鬷��,F_ �f[j�BO>VZb�Ԕ�*[�d��9\V[]���V�~��
���3�c���D6�1��ԜkΔ��fZ�I�� u!��������������(χ�W�o*O��M�7� �^�
�����q�-�6�"��s��{N7�&�)w6*ޚ2��������{��w1xg��b&�!���c����򍨊"�V��8��"mCQ�\~�\��"}�s�X��]�=��4�n9���B�)�As�
$)݅Ѷ��!�m+��s,���MW���,pN<��hj;0�+�.uE�ݡ�9. �]]���Gu��
.B3H�X�Э��ｎ�I�x����#IφE��ם�_=����!,�MG�rQRza�tt�%��s<������М�����``��L���FW����&[q�\8��(N����%x�ȔB�b~�^>yN�w7y~=!����MP�"_<��z� �e�l�W�K�_� L) �he^,�v�e���#���@9�ݚO���M�2-A'�	����2e�jb�_�
�BU�Q�FTbW;��H#��8Ըn�%t���A����K�s_�5V���րE��B+ע2�t���,~�3��x����o�XW�db�
9V���I٦��z��(."�����>�6Ӄw�?�ǵ�_ICC���ş�H�n^X�y<P�
c��e�^�/n���[�č ����C����m���ӿ�I8��K/��
�C�&�,f�ա.����o#�{1Ko�Ϻ��g]�w��$�  �V9����_g]��4B;��%ۖga5YY�T�f�BRR�k�z7�����9�k���J�i\
#$����	�.
�576s:�%�*�$�����M4�3�̆&eq�~�[?�6���Sf6rNs2檁&��h>��ո��W��Yo��|�.a��g7.�	� a�tbl����qY��	���vS�@�tT�`@�.�������]@���`d�quq���|-���,��8�t�Wu:��N�vT|�{4_�sK�&�IXYDՕx���ЭI��?`���2��HrIC�pj�����?��l�n]4�~�*�a�����a��<H+��઩�Ie]c�p?S3z��󬤴sZ�J����C���*g����0��G��	�0�*���4���|�^I�8+���P7���g����{�M��Aa7 I=�30��?�ޟ��"�Z��9'�?
�0w_��-���*��U��b��PQl���aL�����(�v���X5A8#V�G��U���Ov����Ů�_L���]�����Jנ#�]d�'�FB٤\�]q1Sr�s��(��TP�JCP�)+����������UZ���R�e��o�������ۆ뾪'.��o��� �e8d�k�c�U͍�}8�2zi�e��H���8�Y�
ߛ���[Zoڵ��$9���Nط��]ۊ��{�gq��Ҙ9���i��_0[���]4��ϟ�v���Oqoɬц�2�u�I������	�0	�e4�O��9�?I~�=�/�����~0��z2鏍sN�X��&К�,/�=��`��4�<�i������'���8���+KY��T�b�V��*�p�M�zM���V���3�h�B�	��f*h��,��Nt��X�h�X�����9� |k49V���O�'���=E�T���}�7�4誎�?�Hk�3���N �;�9o�Z�z�p�|��z�9̸�\>�@� �?r�r��h�<.iB<�ݖ�Or�a.0�'7R
�߳�j�������%�c
C���~�Tyܸ�I��r����Ԏ;;V�������7�x�e��YcO��|� �/�0�c�-u��j\≎�s+n1�>��wW��W�gF��>�~+�}Wĺ�a y��=R�%<���fx����^1냫,�<_P]�5�i�Q�ˬ����f�5�T� 9��B�d Ø
�Z 3��$[�fS�h^����a�n��,�	��lB�Qe�i)8�(IN�U���`�~y>�9ЄІ}�%e?Eq�
4N��M ��)<RAUy��7��#��w��`Z�9̄F}h��*�l5M>6��#���l�|��a
��A���Ft�{�SG�{��yDs<�a�{�ϙp���Yy	�42H�����{-�5+]qέ����+I-���k�f-)|-))�|��=����W�3%��9
@q뾷�!	��'�s��4��f����΍eL��Zz�sc�;i^���v�qj�D��,�br�e�ܧ
�����?�|ϗx��)���1����H����N����?��T���� ���"r���|<z�
�G2��<��R�3<�{�����%��vþ _����ۅ���1���QCc�)�I�M�c��b�.����$�y���y��g�|5ϊ��9�A<b��fه>G\�i/T��U�B!��0��݆�9smvT�۹3�ă���;
�}p��m��|-(�p�&_���q]ӆ�?�o[�<�$Ny့>�r�I^)����J^�/Y�4�Ko}�����!�Y��dd�n`-�����=��J���7�>ly ��')}��ɏ���xo���{3o�:7�wk|ȟx�Y_�rГl��	N���ht&Z��@��Y��ɮ�п�t:�h���b�4\G=�>�u]�kDc����%��b�¹��yc��~ ��?=Z>P=?�%H�d�7~8������h*��C�.�����h8�d���8<���~-)����M�:A����8��4�)��@�s��7���p1�����̰�ڻ�(���葀�A|��lu_��M;i9�\y�s�lN�S�����-N~rR@���3|z�jz>#7*7���Q��Fr�����[8�^O�-�,�3m���8�4��j��\�r�o�"͠�O���uw[B�=����������B'�?�Vʷ�ыѳ���O�_�K�O�b���яR����cQ�|��k��z���#�!�_���@Y�X��(��%�5��
B�� �+Pw�
��F��H�`��Dg��J�%"3l����������)��9Wơ?&e�֕�c��n<~��%��3�y���%>�8��:�>���Fp��~��\t+���b� (5��2�E�*�K����$��鱄��^�A:��ݍ[u���ieR�����bs=�i�?�����rqo��~1
��qP��5�L�����P:S����Y�8D5�r
$�̇������=pU��9�� �K91�U��߽�L�ń��^�Q��^t����