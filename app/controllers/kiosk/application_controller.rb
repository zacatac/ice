# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Kiosk::ApplicationController < ApplicationController
  
  layout "kiosk/application"
  # helper "kiosk/something"

  # Autocomplete handler for all admin controllers.
  #----------------------------------------------------------------------------
  # def auto_complete
  #   @query = params[:auto_complete_query]
  #   @auto_complete = klass.text_search(@query).limit(10)
  #   render :partial => 'auto_complete'
  # end
  
end
