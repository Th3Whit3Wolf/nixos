final: prev:

{
  vimPlugins = with final.vimUtils;
    prev.vimPlugins // {
        parinfer-rust = buildVimPluginFrom2Nix {
            name = "parinfer-rust";
            version = "5def45e1cbbc4f690fe70e44c786ad6bf9437476";
            src = prev.fetchgit {
                url = "https://github.com/eraserhd/parinfer-rust";
                rev = "5def45e1cbbc4f690fe70e44c786ad6bf9437476";
                fetchSubmodules = false;
                deepClone = false;
                leaveDotGit = false;
                sha256 = "03w1hagbf4pqd84r0mxpdpna701fhkc59zr7clmlb0ymbggz3696";
            };
        };
        ron-vim = buildVimPluginFrom2Nix {
            name = "ron-vim";
            version = "04004b3395d219f95a533c4badd5ba831b7b7c07";
            src = prev.fetchgit {
                url = "https://github.com/ron-rs/ron.vim";
                rev = "04004b3395d219f95a533c4badd5ba831b7b7c07";
                fetchSubmodules = false;
                deepClone = false;
                leaveDotGit = false;
                sha256 = "1xlr8slwcr6b9p33awf8xzdp04myv6dcsxwi50val4vzvzcgyrcl";
            };
        };
        vim-cargo-make = buildVimPluginFrom2Nix {
            name = "vim-cargo-make";
            version = "9f36abd5b6b94bf12af44f6210b5f8836509ff69";
            src = prev.fetchgit {
                url = "https://github.com/nastevens/vim-cargo-make";
                rev = "9f36abd5b6b94bf12af44f6210b5f8836509ff69";
                fetchSubmodules = false;
                deepClone = false;
                leaveDotGit = false;
                sha256 = "11vi7nmisyas27bp8fywq4qgmpdaix9bap2r9i86ip9mjajq96hv";
            };
        };
        vim-duckscript = {
            name = "vim-duckscript";
            version = "3f3683132576cae15c470ac157fc1f6674c563f6";
            src = prev.fetchgit {
                url = "https://github.com/nastevens/vim-duckscript";
                rev = "3f3683132576cae15c470ac157fc1f6674c563f6";
                fetchSubmodules = false;
                deepClone = false;
                leaveDotGit = false;
                sha256 = "1361mn5zxv086r26fn95hc8nkjwq6zmjimvxbxaj9c91pqx90rhg";
            };
        };
    };
}
