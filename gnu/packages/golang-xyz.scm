;;; Copyright © 2021 Ryan Prior <rprior@protonmail.com>

(define-module (gnu packages golang-xyz)
  #:use-module (gnu packages base)
  #:use-module (gnu packages golang)
  #:use-module (guix build-system go)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))


(define-public go-github-com-mitchellh-hashstructure
  (package
    (name "go-github-com-mitchellh-hashstructure")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mitchellh/hashstructure")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0zgl5c03ip2yzkb9b7fq9ml08i7j8prgd46ha1fcg8c6r7k9xl3i"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/mitchellh/hashstructure"))
    (home-page "https://github.com/mitchellh/hashstructure")
    (synopsis "Get hash values for arbitrary values in golang.")
    (description
     "This package can be used to key values in a hash (for use in a map, set,
etc.) that are complex.  The most common use case is comparing two values
without sending data across the network, caching values locally (de-dup), and
so on.")
    (license license:expat)))
