import dotfiles_install as df
import package_install as pkg

if __name__ == '__main__':
    pkg.main()
    dotfiles = df.Dotfiles()
    dotfiles.start()
