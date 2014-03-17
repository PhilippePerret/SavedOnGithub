#Pour définir des matchers customisés

##Usage

    # -- Le test --
    features "<le feature>" do
      ...
      steps "<le scénario>" do
        ...
        it "avec mon matchers customisé" do
          page.should have_with_mon_matcher
        end

##Définition du matcher customisé


    # Quelque part dans ./spec/support
    # Par exemple dans ./spec/support/matchers/mon_matcher
    module Capybara
      class Session
      
        def has_with_mon_matcher?
          @errors = []
          ... des tests comme : ...
          ca = "div#mon_div_dans_la_page"
          @errors << "devrait contenir #{ca}" unless has_css?(ca)
          ...
          @errors.empty? or raise Capybara::ExpectationNotMet, @errors.join(', ') 
        end
