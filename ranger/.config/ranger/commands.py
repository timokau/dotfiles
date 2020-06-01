import subprocess
import os.path

from ranger.api.commands import Command


class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.
    """

    def execute(self):
        # TODO integrate with locate, z
        # TODO bfs?
        command = "fd --color=always --hidden --follow --no-ignore-vcs 2>/dev/null | fzf --ansi +m"
        fzf = self.fm.execute_command(
            command, universal_newlines=True, stdout=subprocess.PIPE
        )
        stdout, _stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip("\n"))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)

class fzf_locate(Command):
    """
    :fzf_locate

    Find a file using fzf with locate indexing.
    """

    def execute(self):
        command = "locate home | fzf +m"
        fzf = self.fm.execute_command(
            command, universal_newlines=True, stdout=subprocess.PIPE
        )
        stdout, _stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip("\n"))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)
