#TM Command pour faire des tests d'application

##Définition de la commande
<dl>
  <dt>Name</dt>
  <dd>Run as test</dd>
  <dt>scope</dt>
  <dd>source.rb</dd>
  <dt>Key equivalent</dt>
  <dd>CMD + ALT + R</dd>
  <dt>Input</dt>
  <dd>Document</dd>
  <dt>Format input</dt>
  <dd>Text</dd>
  <dt>Output</dt>
  <dd>Show in new window</dd>
  <dt>Format Output</dt>
  <dd>HTML</dd>
</dl>

##Requis

*Note&nbsp;: `./` ci-dessous correspond à la racine du site à tester.*

* **Le dossier `./_Docs/tests/`** contenant les libraires et les tests. *Cf. le dossier dans l'atelier Icare version "Ruby"*.
* **Le fichier `./data/secret/data_su.rb`** définissant au moins DATA_SUPER_USER[:password]

## code à copier dans la command TM

    #!/usr/bin/env ruby

    # Pour pouvoir utiliser CMD+R en utilisant des sorties couleurs
    Dir.chdir(ENV['TM_PROJECT_DIRECTORY']) do
      # eval STDIN.read
      require './data/secret/data_su'
      if defined?(DATA_SUPER_USER)
        file_path = ENV['TM_FILEPATH']
        puts `echo "#{DATA_SUPER_USER[:password]}" | sudo -S ruby -e "require '#{file_path}'"`
      else
        puts "DATA_SUPER_USER doit être défini, comme table contenant :password, le mot de passe pour la session d'ordinateur courante."
      end
    end

##Exemple de code

Dans un fichier de nom quelconque (par exemple `_main_.rb`) placé n'importe où mais dans la hiérarchie du site testé.

    =begin

    Test automatique

    Pour lancer le test : CMD + ALT + R

    =end

    MODE_TESTS = true
    require './_Docs/tests/lib/required.rb'

    # Messages retournés
    # ------------------
    puts "Dossier courant : #{Dir.pwd}"
    puts "Salut tout le monde !", BLUE
    puts "Salut tout le monde !", RED
    puts "Salut tout le monde !", GREEN
