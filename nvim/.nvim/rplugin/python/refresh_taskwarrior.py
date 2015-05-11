import neovim
import time

@neovim.plugin
class TaskwarriorRefresh(object):
    def __init__(self, vim):
        self.vim = vim
        self.focus = True

    @neovim.autocmd('FocusLost', pattern='*', eval='expand("<afile>")',
                    sync=False)
    def taskreport_handler(self, filename):
        self.focus = True
        self.vim.command("echo 'focuslost'")
        while not self.focus:
            self._refresh()
            self.vim.command("echo 'refreshed'")
            time.sleep(5)

    @neovim.autocmd('FocusGained', pattern='*', eval='expand("<afile>")',
                    sync=False)
    def moved_handler(self, filename):
        self.focus = True
        self.vim.command("echo 'stopped'")

    def _refresh(self):
        self.vim.command("normal R")
