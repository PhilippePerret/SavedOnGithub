#Utile pour les propriétaires

Propriétaire d'un fichier :

    owner_uid = File.stat(path/to/file).uid
    # => p.e. 501

Obtenir le nom&nbsp;:
    
    require 'etc'
    owner_name = Etc::getpwuid(owner_uid)
    # => p.e. 'philippeperret'