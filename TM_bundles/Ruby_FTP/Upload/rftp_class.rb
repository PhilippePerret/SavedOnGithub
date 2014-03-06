#!/usr/bin/env ruby

require 'net/ftp'

class RFTP
  class << self
    
    # = Main =
    # 
    # Upload du fichier courant
    def upload
      operate :upload
    end
    # Remove du fichier courant
    def remove
      operate :remove
    end
    # Listing du dossier où se trouve le fichier courant
    def list
      operate :list_folder
    end
    
    def operate operation
      # On se place sur le dossier racine
      puts_infos_courante
      Dir.chdir(project_folder) do
        puts ""
        error :bad_ruby_version   unless ruby_version_ok?
        error :data_file_required unless data_ftp_exists?
        error :data_required      unless required_data_ok?
      end
      # proceed_operation :upload
      # proceed_operation :remove
      proceed_operation operation
    end
    
    # Procède à l'opération FTP voulue
    # @param {Symbol} operation   L'opération, entre :upload, :remove et :list
    def proceed_operation operation
      puts "\n"+('-'*78)+"\n\n"
      puts "Opération demandée : #{operation.inspect}"
      puts "------------------\n"
      @ftp = Net::FTP.new(RFTP_DATA[:host], RFTP_DATA[:username],RFTP_DATA[:password])
      begin
        puts "\nMessage d'accueil :"
        puts   "-----------------"
        puts "#{@ftp.welcome}\n"
        
        # On se place sur le dossier local et le même dossier distant
        local_folder    = File.join(project_folder, current_file_folder)
        distant_folder  = '/' + File.join(RFTP_DATA[:dis_root], current_file_folder)
        # On crée si nécessaire les dossiers jusqu'au dossier distant
        create_folders_upto distant_folder

        Dir.chdir   local_folder
        @ftp.chdir  distant_folder
        
        # puts "ENTRÉES LOCALES :"
        # puts "    " + Dir.entries(local_folder).reject{|e| e.start_with?('.')}.join("\n    ")
        # puts "ENTRÉES DISTANTES :"
        # puts "    " + @ftp.nlst.reject{|e| e.start_with?('.')}.join("\n    ")
        
        puts "\nRésultat :"
        puts   "--------"
        case operation

        when :upload

          # === Upload du fichier ===

          @ftp.putbinaryfile(current_file_path, current_file_name)
          raise :distant_file_unfound unless @ftp.nlst.include?(current_file_name)
          puts "Upload de #{current_file_name} OK"

        when :remove
          
          # === Destruction du fichier ===
          
          @ftp.delete(current_file_name)
          raise :distant_file_should_not_exist if @ftp.nlst.include?(current_file_name)
          puts "Remove de #{current_file_name} OK"

        when :list_folder
          
          # === Listing du dossier du fichier ===
          
          puts "ENTRÉES DISTANTES DE #{distant_folder} :"
          liste = @ftp.nlst.reject{|e| e.start_with?('.')}
          if liste.count > 0
            puts "    - " + liste.join("\n-    ")
          else
            puts "    - aucune -"
          end
        end
        
      rescue Exception => e
        error e.message
      ensure
        @ftp.close
      end
    end
    
    # Créer les folders distant jusqu'au dossier +dossier+
    def create_folders_upto dossier
      
      dfolder_grow = ['/']
      dfolder_rest = dossier.split('/')
      dfolder_rest.shift
      
      while name = dfolder_rest.shift
        folder    = File.join( dfolder_grow )
        @ftp.chdir folder
        unless @ftp.nlst.include? name
          @ftp.mkdir( name )
          puts "--> #{folder}/#{name} créé avec succès"
        end
        dfolder_grow << name
      end
    end
    
    def error err_id
      err = case err_id
      when :distant_file_should_not_exist
        "Le fichier distant devrait avoir été détruit. Il existe toujours…"
      when :distant_file_unfound
        "Le fichier distant est introuvable, même après l'upload…"
      when :bad_ruby_version
        "La version ruby doit être 2 ou supérieur"
      when :data_file_required
        "Le fichier #{path_data} doit exister (et contenir toutes les données requises)."
      when :data_required
        "Les données RFTP_DATA doivent exister et être valides :\n"+
        <<-DOC
RFTP_DATA = {
  :host       => <l'hôte> p.e. "ftp.my_host.net",
  :port       => 21,
  :username   => "<user name>",
  :password   => "<password>",
  :dis_root   => "www",           # le dossier racine distant
  # :loc_root   => "/PATH/TO/LOCAL/ROOT/FOLDER" # inutile dans cette version
}
        DOC
      else 
        err_id
      end
      puts "\n### ERROR : #{err}"
      exit(256)
    end
    
    def puts_infos_courante
      len = 20
      puts "="*78
      puts "= #{'Projet'.ljust(len)} : #{project_name}"
      puts "= #{'Full-path'.ljust(len)} : #{project_folder}"
      puts "= #{'Fichier courant'.ljust(len)} : ./#{current_file_relpath}"
      puts "= #{'Dossier relatif'.ljust(len)} : ./#{current_file_folder}"
      puts "="*78
    end
    
    # --- Tests ---
    def ruby_version_ok?
      @ruby_version_ok ||= begin
        ok = RUBY_VERSION.to_i >= 2
        puts "#{'Version Ruby'.ljust(20)} -- OK" if ok
        ok
      end
    end
    def data_ftp_exists?
      @data_ftp_exists = begin
        ok = File.exists? path_data
        puts "#{'Fichier data_rftp'.ljust(20)} -- OK" if ok
        ok
      end
    end
    def required_data_ok?
      require path_data
      return false unless defined? RFTP_DATA
      return false unless 
        RFTP_DATA.has_key?( :host ) &&
        RFTP_DATA.has_key?( :port ) &&
        RFTP_DATA.has_key?( :username ) &&
        RFTP_DATA.has_key?( :password ) &&
        RFTP_DATA.has_key?( :dis_root ) #&&
        # RFTP_DATA.has_key?( :loc_root )
      puts "#{'Data RFTP_DATA'.ljust(20)} -- OK"
      return true
    end
    
    # Fichier courant
    # ---------------
    def current_file_name
      @current_file_name ||= File.basename(current_file_path)
    end
    def current_file_path
      @current_file ||= ENV['TM_FILEPATH']
    end
    def current_file_relpath
      @current_file_relpath ||= current_file_path.sub(/#{project_folder}\//, '')
    end
    def current_file_folder
      @current_file_folder ||= begin
        d = current_file_relpath.split('/')
        d.pop
        File.join(d)
      end
    end
    
    # Infos projet courant
    # ---------------------
    def project_folder
      @project_folder ||= ENV['TM_PROJECT_DIRECTORY']
    end
    def project_name
      @project_name ||= File.basename(project_folder)
    end
    
    def path_data
      @path_data ||= File.join('.', 'data', 'secret', 'data_rftp.rb')
    end
  end # / class << self
end


