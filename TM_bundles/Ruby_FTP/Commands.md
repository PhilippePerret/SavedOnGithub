#Ruby FTP

Permet d'uploader/détruire le fichier courant sur un site distant.

* Créer un Bundle `_Phil : RFTP`.
* Placer dans ce bundle (./Library/Application Support/Avian/bundles/) un dossier `Support` et y placer le fichier `rftp_class.rb`.
* Créer les trois commandes ci-dessous.

# Command “Upload”

Code :

    #!/usr/bin/env ruby
    
    require "#{ENV['TM_BUNDLE_SUPPORT']}/rftp_class.rb"
    RFTP::upload

Cf. [Détail ci-dessous](#detail_infos).

#Command “Remove”

Code&nbsp;:

    #!/usr/bin/env ruby
    
    require "#{ENV['TM_BUNDLE_SUPPORT']}/rftp_class.rb"
    RFTP::remove

Cf. [Détail ci-dessous](#detail_infos).

#Command “List”

(Permet de liste le contenu du dossier contenant le fichier courant)

Code&nbsp;:

    #!/usr/bin/env ruby
    
    require "#{ENV['TM_BUNDLE_SUPPORT']}/rftp_class.rb"
    RFTP::list

Cf. [Détail ci-dessous](#detail_infos).


<a name="detail_infos"></a>
##Détail des infos

Infos :

    Name              Upload Current File
    Key equivalent    CMD + U
    
    Name              Remove Current Distant File
    Key equivalent    - aucune -
    
    Name              List Folder Distant File
    Key equivalent    CMD + MAJ + L
    
    
    Scope selector    source.ruby, source.css, source.js, source.yaml, text.html.markdown
    Tab trigger       ---
    Save              Nothing
    Input             Nothing
    Output            Show in Tool Tip
    
    