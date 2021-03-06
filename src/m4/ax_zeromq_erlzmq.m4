# -*- coding: utf-8; Mode: m4; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-
# ex: set softtabstop=4 tabstop=4 shiftwidth=4 expandtab fileencoding=utf-8:
#
# SYNOPSIS
#
#   AX_ZEROMQ_ERLZMQ
#
# DESCRIPTION
#
#   Build the ZeroMQ Erlang bindings
#
#   This macro sets:
#
#     ZEROMQ_ERLZMQ_RELTOOL
#     ZEROMQ_ERLZMQ_APPCONF
#
# BSD LICENSE
# 
# Copyright (c) 2011-2012, Michael Truog
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#     * All advertising materials mentioning features or use of this
#       software must display the following acknowledgment:
#         This product includes software developed by Michael Truog
#     * The name of the author may not be used to endorse or promote
#       products derived from this software without specific prior
#       written permission
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
#

AC_DEFUN([AX_ZEROMQ_ERLZMQ],
[
    AC_REQUIRE([AC_ERLANG_SUBST_ROOT_DIR])
    AC_REQUIRE([AX_ERLANG_REQUIRE_OTP_VER])
    AC_REQUIRE([AX_ZEROMQ])

    AC_MSG_CHECKING(for ZeroMQ's Erlang interface)
    if test "x$ZEROMQ_VERSION_MAJOR" = "x"; then
        AC_MSG_RESULT(no)
        ZEROMQ_ERLZMQ_RELTOOL=""
        ZEROMQ_ERLZMQ_APPCONF=""
    else
        AC_MSG_RESULT(building)
        AX_ERLANG_REQUIRE_OTP_VER([R14B02], ,
            [AC_MSG_ERROR([Erlang >= R14B02 required for erlzmq usage in cloudi_job_zeromq])])
        abs_top_srcdir=`cd $srcdir; pwd`
        AC_CONFIG_COMMANDS([zeromq_erlzmq],
            [(cd $SRCDIR/external/zeromq/v$ZEROMQ_VERSION_MAJOR/erlzmq/ && \
              ZEROMQ_CFLAGS=$ZEROMQ_CFLAGS \
              ZEROMQ_LDFLAGS=$ZEROMQ_LDFLAGS \
              ZEROMQ_LIB_PATH=$ZEROMQ_LIB_PATH \
              $BUILDDIR/rebar compile && \
              echo "erlzmq locally installed" || exit 1)],
            [ZEROMQ_CFLAGS=$ZEROMQ_CFLAGS
             ZEROMQ_LDFLAGS=$ZEROMQ_LDFLAGS
             ZEROMQ_LIB_PATH=$ZEROMQ_LIB_PATH
             ZEROMQ_VERSION_MAJOR=$ZEROMQ_VERSION_MAJOR
             ERLANG_ROOT_DIR=$ERLANG_ROOT_DIR
             SRCDIR=$abs_top_srcdir
             BUILDDIR=$abs_top_builddir])
        ZEROMQ_ERLZMQ_RELTOOL="{app, erlzmq, @<:@{incl_cond, include}@:>@},"
        ZEROMQ_ERLZMQ_APPCONF="erlzmq,"
    fi
    AC_SUBST(ZEROMQ_ERLZMQ_RELTOOL)
    AC_SUBST(ZEROMQ_ERLZMQ_APPCONF)
])
