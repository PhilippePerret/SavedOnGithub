#TM Command pour faire des tests d'application

Dans TextMate :

* CMD + ALT + CTRL + B (=> les Bundles s'ouvrent)&nbsp;;
* Choisir l'emplacement de la commande dans un Bundle&nbsp;;
* CMD + N (=> La fenêtre pour créer une nouvelle chose)&nbsp;;
* Choisir "Command" (ou taper "c" "o")
* Définir la commande à l'aide de [Définition de la commande](#define_command)
* Copier-coller le [code de la commande](#command_code)
* Définir les tests en respectant les [éléments requis](#required)

<a name="define_command"></a>
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

<a name="required"></a>
##Requis

*Note&nbsp;: `./` ci-dessous correspond à la racine du site à tester.*

* **Le dossier `./tests/`** contenant les libraires et les tests. *Cf. le dossier dans l'atelier Icare version "Ruby"*&nbsp;;
* **Le fichier `./tests/_main_.rb`** qui lance les tests. *Cf. le dossier dans l'atelier Icare version "Ruby"*&nbsp;;
* **Le fichier `./data/secret/data_su.rb`** définissant au moins DATA_SUPER_USER[:password]&nbsp;;
* **La définition de FILES_OWNER_WWW** dans `./tests/lib/files_owner_www.rb` pour savoir quels fichiers/dossiers doivent retrouver le propriétaire `_www` après les tests (ce sont les dossiers et fichiers qui sont utilisés — write — par l'application).

<a name="command_code"></a>
## code à copier dans la command TM

    #!/usr/bin/env ruby

    Dir.chdir(ENV['TM_PROJECT_DIRECTORY']) do
      begin
        require './data/secret/data_su'
        if defined?(DATA_SUPER_USER)
          file_path = ENV['TM_FILEPATH']
          puts `echo "#{DATA_SUPER_USER[:password]}" | sudo -S ruby -e "require './tests/_main_.rb'"`
        else
          puts "DATA_SUPER_USER doit être défini, comme table contenant :password, le mot de passe pour la session d'ordinateur courante."
        end
      rescue Exception => e
        puts e.message, RED
        puts e.backtrace.join('<br>'), RED
      ensure
        # Il faut remettre le propriétaire _www
        require './tests/lib/files_owner_www' if File.exists?('./tests/lib/files_owner_www.rb')
        if defined? FILES_OWNER_WWW
          FILES_OWNER_WWW.each do |path|
            fullpath = File.join('.', path)
            cmd = File.directory?(fullpath) ? 'chown -R' : 'chown'
            `echo "#{DATA_SUPER_USER[:password]}" | sudo -S #{cmd} _www '#{fullpath}'`
          end
        else
          puts "FILES_OWNER_WWW must be defined in ./tests/lib/required.rb (due to know which files own to _www)"
        end
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
