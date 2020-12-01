;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2020 Ryan Prior <rprior@protonmail.com>
;;; Copyright © 2020 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2020 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2021 (unmatched parenthesis <paren@disroot.org>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages vlang)
  #:use-module (gnu packages digest)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages javascript)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages node)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages valgrind)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system gnu)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages))

(define markdown-origin
  (let ((markdown-version "1ccfbcba945b649b61738b9c0455d31cf99564b2"))
    (origin
      (method git-fetch)
      (uri (git-reference
            (url "https://github.com/vlang/markdown")
            (commit markdown-version)))
      (file-name (git-file-name "vlang-markdown" markdown-version))
      (sha256
       (base32 "0s982qiwy4s9y07x9fsy4yn642schplhp9hrw2libg2bx4sw43as")))))

(define-public vlang
  (package
   (name "vlang")
   (version "0.2.4")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/vlang/v")
           (commit version)))
     (file-name (git-file-name name version))
     (sha256
      (base32 "17wmjxssmg6kd4j8i6pgib452zzwvkyi3n1znd1jj3xkf2l92fw8"))
     (modules '((guix build utils)))
     (snippet
      '(begin
         ;; Eventually remove the whole thirdparty directory.
         (delete-file-recursively "thirdparty/bignum")
         (delete-file-recursively "thirdparty/cJSON")))))
   (build-system gnu-build-system)
   (arguments
    `(#:make-flags
      (list (string-append "CC=" ,(cc-for-target))
            "TMPTCC=tcc"
            (string-append "VC=" (assoc-ref %build-inputs "vc"))
            "GITCLEANPULL=true"
            "GITFASTCLONE=mkdir -p"
            "TCCREPO="
            "VCREPO="
            (string-append "VFLAGS=-cc " ,(cc-for-target))
            "VERBOSE=1")
      #:phases
      (modify-phases %standard-phases
        (delete 'configure)
        (add-before 'build 'change-home
          (lambda _
            (setenv "HOME" "/tmp")
            #t))
        (add-before 'build 'patch-files
          (lambda* (#:key inputs #:allow-other-keys)
            (substitute* "Makefile"
              (("rm -rf") "true")
              (("--branch thirdparty-unknown-unknown") ""))
            (substitute* "vlib/math/big/big.v"
              (("@VROOT/thirdparty/bignum")
               (string-append (assoc-ref inputs "tiny-bignum") "/share")))
            (substitute* "vlib/json/json_primitives.v"
              (("@VROOT/thirdparty/cJSON")
               (assoc-ref inputs "cJSON")))))
        (add-before 'build 'patch-cc
          (lambda _
            (let* ((bin "tmp/bin")
                   (gcc (which "gcc")))
              (mkdir-p bin)
              (symlink gcc (string-append bin "/cc"))
              (setenv "PATH" (string-append bin ":" (getenv "PATH"))))
            #t))
        (add-after 'build 'build-tools
          (lambda* (#:key inputs #:allow-other-keys)
            (copy-recursively (assoc-ref inputs "vmodules/markdown") "vmodules/markdown")
            (setenv "VMODULES" (string-append (getcwd) "/vmodules"))
            (invoke "./v" "build-tools" "-v")
            #t))
        (add-before 'check 'fix-or-delete-failing-tests
          (lambda _
            ;; The x64 tests copy .vv files into the test directory and then
            ;; write to them, so we need to make them writeable.
            (for-each (lambda (vv) (chmod vv #o644))
                      (find-files "vlib/v/gen/x64/tests/" "\\.vv$"))
            ;; The process test explicitly calls "/bin/sleep" and "/bin/date"
            (substitute* "vlib/os/process_test.v"
              (("/bin/sleep") (which "sleep"))
              (("/bin/date") (which "date")))
            ;; The valgrind test can't find `cc' even though it's on PATH, so
            ;; we pass it as an explicit argument.
            (substitute* "vlib/v/tests/valgrind/valgrind_test.v"
              (("\\$vexe") "$vexe -cc gcc"))
            (for-each delete-file
                      '(;; XXX As always, these should eventually be fixed and run.
                        "vlib/vweb/tests/vweb_test.v"
                        "vlib/v/tests/live_test.v"
                        "vlib/v/tests/repl/repl_test.v"))
            #t))
        (replace 'check
          (lambda* (#:key tests? #:allow-other-keys)
            (let* ((bin "tmp/bin")
                   (gcc (which "gcc")))
              (when tests?
                (mkdir-p bin)
                (symlink gcc (string-append bin "/cc"))
                (setenv "PATH" (string-append bin ":" (getenv "PATH")))
                (invoke "./v" "test-self")))
            #t))
        (replace 'install
          (lambda* (#:key outputs #:allow-other-keys)
            (let* ((bin (string-append (assoc-ref outputs "out") "/bin"))
                   (cmd (string-append bin "/cmd"))
                   (thirdparty (string-append bin "/thirdparty"))
                   (vlib (string-append bin "/vlib"))
                   (vmodules (string-append bin "/vmodules"))
                   (vmod (string-append bin "/v.mod")))
              (mkdir-p bin)
              (copy-file "./v" (string-append bin "/v"))
              ;; v requires as of 0.2.4 that these other components are in the
              ;; same directory. In a future release we may be able to move
              ;; these into other output folders.
              (copy-recursively "cmd" cmd)
              (copy-recursively "thirdparty" thirdparty)
              (copy-recursively "vlib" vlib)
              (copy-file "v.mod" vmod))
            #t)))))
   (inputs
    `(("glib" ,glib)
      ("tiny-bignum" ,tiny-bignum)
      ("cJSON" ,(package-source cjson))))
   (native-inputs
    `(("vc"
       ;; Versions are not consistently tagged, but the matching commit will
       ;; probably have ‘v0.x.y’ in the commit message.
       ,(let ((vc-version "5e876c1491db50b136499d3397b57b7c062040e5"))
          ;; v bootstraps from generated c source code from a dedicated
          ;; repository. It's readable, as generated source goes, and not at all
          ;; obfuscated, and it's about 15kb. The original source written in
          ;; golang is lost to the forces of entropy; modifying the generated c
          ;; source by hand has been a commonly used technique for iterating on
          ;; the codebase.
          (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/vlang/vc")
                  (commit vc-version)))
            (file-name (git-file-name "vc" vc-version))
            (sha256
             (base32 "1gxdkgc7aqw5f0fhch1n6nhzgzvgb49p77idx1zj7wcp53lpx5ng")))))
      ("vmodules/markdown" ,markdown-origin)
      ("git" ,git-minimal)
      ;; For the tests.
      ("libx11" ,libx11)
      ("node" ,node)
      ("openssl" ,openssl)
      ("ps" ,procps)
      ("sqlite" ,sqlite)
      ("valgrind" ,valgrind)))
   (native-search-paths
    (list (search-path-specification
           (variable "VMODULES")
           (files '("bin/")))))
   (home-page "https://vlang.io/")
   (synopsis "Compiler for the V programming language")
   (description
    "V is a systems programming language.  It provides memory safety and thread
safety guarantees with minimal abstraction.")
   (license license:expat)))
