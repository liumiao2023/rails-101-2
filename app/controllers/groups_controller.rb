class GroupsController < ApplicationController

  before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destory]
  before_action :find_group_and_check_premission, only: [:edit, :update, :destory]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end


  def create
    @group = Group.new(group_params)
    @group.user = current_user

    if @group.save
      current_user.join!(@group)
      redirect_to groups_path
    else
      render :new
    end
  end

  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
  end

  def edit
  end

  def update
  if @group.update(group_params)
    redirect_to groups_path, notice: "Update Success"
  else
    render :edit
  end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_path, alert: "Group deleted"
  end

def join
  @group = Group.find(params[:id])

  if !current_user.is_member_of?(@grop)
    current_user.join!(@group)
    flash[:notice] = "加入本讨论版成功！"
  else
    flash[:warning] = "你已经是本讨论版成员了！"
  end

  redirect_to groups_path(@group)

end

def quit
  @group = Group.find(params[:id])

  if !current_user.is_member_of?(@grop)
    current_user.quit!(@group)
    flash[:notice] = "已经退出本讨论版！"
  else
    flash[:warning] = "你不是本讨论版成员，怎么退出？"
  end

  redirect_to groups_path(@group)
end

private

def find_group_and_check_premission
  @group = Group.find(params[:id])

  if current_user != @group.user
    redirect_to root_path, alert: "You have no premission."
  end
end

def group_params
  params.require(:group).permit(:title, :description)
end

end
