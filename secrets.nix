let 
    inherit (builtins) readDir baseNameOf attrNames
        elem listToAttrs isList concatMap map trace
        elemAt length;

    assertMsg = pred: msg:
        if pred then
            true
        else 
            trace msg false;

    flatten = x:
        if isList x then 
            concatMap (y: flatten y) x
        else 
            [x];

    forEach = xs: f: map f xs;

    mapAttrsToList = f: attrs:
        map (name: f name attrs.${name}) (attrNames attrs);

    only = list:
        assert assertMsg (length list == 1 ) "lists.only: list must not be empty!";
    elemAt list 0;

    getHostPath = hostname: only(flatten (
        mapAttrsToList (name: type: if type == "directory" then 
            mapAttrsToList (Name: Type: if Type == "directory" && Name == hostname then
                "hosts/${name}/${Name}"
            else
                [])(readDir (./hosts + "/${name}"))
        else 
            []
    )(readDir ./hosts)));
    
    /*
        To use a key as a user password:
        1. run `nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd` and enter the desired password
        2. copy the hash the previous command generated
        3. run `ragenix -e PATH/TO/SECRET.AGE` and enter the hash
    */
    allSystems = {
        nebula = {
            system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4uh/pn9MjRmv1duYAm9RzLt3AEHOTLB3/ZK05SOryl";
            users = {
                doc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkTHayoIuYcgRsNeCmKkECGElPEE/WGeSn9oftnatbV";
            };
        };
        tardis = {
            system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMKb+gCXK0YpZ2ywh4B73FmHhZGAVurew3slpRdXHnEf";
            users = {
                doc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdYWa1JPLi3jbXQoOxg+TOaW/Ug5d0TQcR1zcybQcVy";
            };
        };
    };



    hostSecrets = listToAttrs ( flatten (
        forEach (attrNames allSystems) (host: 
            forEach (attrNames allSystems.${host}.users) (user: {
                name = "${getHostPath host}/secrets/${user}.age";
                value = { 
                    publicKeys = [
                        allSystems.${host}.system
                        allSystems.${host}.users.${user}
                    ];
                };
            }
            
        ) ++ [
            {
                name = "${getHostPath host}/secrets/root.age";
                value = { 
                    publicKeys = [
                        allSystems.${host}.system
                        allSystems.${host}.users.${elemAt (attrNames allSystems.${host}.users) 0}
                    ];
                };
            }
        ])
    ));

    vpnUsers = [
        allSystems.nebula.users.doc
        allSystems.tardis.users.doc    
    ];

    vpnFiles = map (x: "secrets/vpn/${x}") [
        "pia.age"
        "expressVPN/auth.age"
        "expressVPN/ca.age"
        "expressVPN/cert.age"
        "expressVPN/key.age"
        "expressVPN/tls_auth.age"
    ];
    vpnSecrets = listToAttrs (forEach vpnFiles (vpnFile: {
        name = vpnFile;
        value = { 
            publicKeys =  vpnUsers;
        };
    }));


in hostSecrets // vpnSecrets
/*
{
    inherit allSystems secrets getHostPath;
}

let secrets = (import ./secrets.nix).secrets; allSystems = (import ./secrets.nix).allSystems;  getHostPath = (import ./secrets.nix).getHostPath; in builtins.listToAttrs secrets
*/
