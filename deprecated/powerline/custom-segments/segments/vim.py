# vim:fileencoding=utf-8:noet
from __future__ import absolute_import, division

try:
    import vim
except ImportError:
    vim = {}  # NOQA

from powerline.theme import requires_segment_info

@requires_segment_info
def zoom_indicator(pl, segment_info, text='ZOOM'):
    '''Return a zoom mode indicator.

    :param string text:
        text to display if zoomed mode is enabled
    '''
    return text if vim.eval('g:ZoomWin == winnr()') != '0' else None

