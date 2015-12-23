# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START helper_methods]
class ApplicationController < ActionController::Base
  # before_action :authenticate
  #
  # def authenticate
  #   redirect_to :login unless User.find_by_provider_and_uid(auth["provider"], auth["uid"])
  # end
  helper_method :logged_in?, :current_user

  def logged_in?
    session.has_key? :user
  end

  def current_user
    Marshal.load session[:user] if logged_in?
  end
# [END helper_methods]

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
