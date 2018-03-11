class CommentsController < ApplicationController
before_action :set_article

def create
  unless current_user
     @comment = @article.comments.build(comment_params)
    if @comment.save
      ActionCable.server.broadcast "comments", render(partial: "comments/comment", object: @comment)
      flash[:notice] = "Comment has been created"

    else
      flash[:alert] = "Comment has not been created"
    end
redirect_to article_path(@article)
  else
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      ActionCable.server.broadcast "comments", render(partial: "comments/comment", object: @comment)
      flash[:notice] = "Comment has been created"
    else
      flash[:alert] = "Comment has not been created"
    end
    redirect_to article_path(@article)
  end
end

 def edit
        @comment = Comment.find(params[:id])
if user_signed_in?
      unless @comment.user === current_user
        flash_message = "Only the owner can edit the comment."
        flash[:alert] = flash_message
redirect_to article_path(@article)
      end
    else
      flash_message = "You need to sign in before continue."
      flash[:alert] = flash_message
      redirect_to new_user_session_path
    end
        end

        def update
         @comment = Comment.find(params[:id])
         @article = @comment.article
unless @comment.user === current_user
      flash_message = "Only the owner can edit the comment."
      flash[:alert] = flash_message
      redirect_to article_path(@article)
    else
         if @comment.update(comment_params)
        flash[:success] = "comment has been updated"
        redirect_to article_path(@article)
      else
        flash.now[:danger] = "comment has not been updated"
        render :edit
      end
end
end


def destroy
if user_signed_in?
        @article = Article.find(params[:article_id])
        @comment = @article.comments.find(params[:id])
        if @comment.destroy
 flash[:success] = "comment has been deleted"
        redirect_to article_path(@article)
     
end
else
      flash_message = "You need to sign in before continue."
      flash[:alert] = flash_message
      redirect_to new_user_session_path
    end
end
    



private
  def comment_params
    params.require(:comment).permit(:body)
  end

  def set_article
    @article = Article.find(params[:article_id])
  end

end
