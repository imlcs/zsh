apt install -y zsh unzip zip

mv $HOME/.vim $HOME/.vimrc /tmp

wget https://github.com/imlcs/vim/archive/refs/heads/master.zip -O $HOME/vim.zip  && unzip $HOME/vim.zip && rm -f $HOME/vim.zip


mv $HOME/vim-master/.vim $HOME/vim-master/.vimrc $HOME && rm -fr $HOME/vim-master

wget https://github.com/imlcs/zsh/archive/refs/heads/master.zip -O $HOME/zsh.zip  && unzip $HOME/zsh.zip && rm -f $HOME/zsh.zip

mv $HOME/zsh-master/custom_function.sh /etc/profile.d 
mv $HOME/zsh-master/.zshrc $HOME/zsh-master/.oh-my-zsh $HOME && /bin/rm -fr $HOME/zsh-master
