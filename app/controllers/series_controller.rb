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

class SeriesController < ItemsController
  def initialize
    @item_type=Serie
  end
  def index
    @items, @more = @item_type.query kind: "Serie", limit: PER_PAGE, cursor: params[:more]
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render  json: @items }
    end
  end

end
