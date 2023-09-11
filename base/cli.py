import functools


class CLI(object):
    def __init__(self, name, desc):
        self._name = name
        self._desc = desc
        self._parser = None
        pass

    def cmd(self, f):
        @functools.wraps(f)
        def patched_func(*args, **kwargs):
            pass
        return patched_func

    def parser():
        if not self._parser:
            p = argparse.ArgumentParse(self.name, self.desc, epilog="yes you are come")

        pass

    pass


class Func(object):
    def __init__(self, name, args=[]):
        pass
    pass


class Arg(object):
    def __init__(self, name, _type):
        self.name = name
        self.type = _type
        pass
    pass


def inspect_func(f):
    desc, params = _parse_docstring(func.__doc__)
    sig = inspect.signature(f)
    args = []
    for param in sig.parameters.values():
        param.name
        # args.append(_param2args(param, param.name)))
    return desc, args


def subcmd(f):
    @functools.wraps(f)
    def patched_func(*args, **kwargs):
        pass
    return patched_func


def _parse_docstring(text):
    return "123", []


def _param2args(param, doc_param=None):
    if param.kind != param.POSITIONAL_OR_KEYWORD:
        raise ValueError('parameter type %s is not yet supported' % param.kind)

    arg_name = '%s%s' % ('--' if len(param.name) > 1 else '-', param.name.replace('_', '-'))  # noqa
    arg_required = param.default is _empty
    arg_default = param.default
    arg_help = doc_param[1] if doc_param else None

    if param.annotation is not _empty:
        arg_type = param.annotation
    elif param.default is not None and param.default is not _empty:
        arg_type = type(param.default)
    else:
        arg_type = str

    return arg_name, arg_type, arg_default, arg_required, arg_help
