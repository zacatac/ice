# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

class UploadJob
  include SuckerPunch::Job
  workers 2

  def perform(file_contents, category, current_user)
    ActiveRecord::Base.connection_pool.with_connection do    
      head = true
      saved = 0
      data = {      
        :user_id => current_user.id,
        :assigned_to => current_user.id,
        :category => category,
        :subscribed_users => nil,
        :name => nil,
        :email => nil,
        :codename => nil,
        :birth => nil
      }

      CSV.parse(file_contents) do |row|
        if head
          headers = row.map{ |x| x.downcase }
          head = false
        else
          next if row[0].nil? or row[1].nil? or row[5].nil? or row[3].nil?
          data[:name] = "#{row[0].strip.capitalize} #{row[1].strip.capitalize}"
          data[:email] = "#{row[4].strip.downcase}"  
          @comment_body = "Visited: #{row[5].strip}"
          data[:codename] = "#{row[6].strip.upcase}"
          data[:birth]= "#{row[3].strip}"
          data.delete_if { |k,v| k==:birth and v[0]=="0" }
          next if /[Tt]est/.match(data[:name])
          next if /[Tt]est/.match(data[:codename])
          next if data[:name].length > 63

          @account = Account.new()        
          @account.assign_attributes(data)
          if @account.save
            @account.add_comment_by_user(@comment_body, current_user)
            saved += 1          
          else 
            @account = Account.where(name: data[:name]).first
            if @account.nil?
              puts "Why was this not uploaded?"
            else
              @comments = Comment.find_all_by_commentable_id(@account.id)
              similar = false
              @comments.each  do |comment| 
                if comment[:comment] == @comment_body
                  similar = true
                end
              end 
              unless similar               
                @account.add_comment_by_user(@comment_body, current_user)
              end
            end
          end
        end
      end        
    end
  end
end
