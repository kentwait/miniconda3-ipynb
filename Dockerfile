FROM kentwait/miniconda3
MAINTAINER Kent Kawashima <kentkawashima@gmail.com>

ENV WORKDIR=/root

RUN apk update && apk upgrade \
 # essentials
 && apk add --no-cache --virtual temp-pkgs build-base python 

RUN cd ${WORKDIR} \
 # Install conda essentials
 && conda update --all --yes \
 && conda install -q -y ipython jupyter \
 && conda clean --all --yes \
 && mkdir -p ${WORKDIR}/notebooks \
 # disable conda jupyter extensions until they are working properly
 && python -m nb_conda_kernels.install --disable --prefix=root \
 && jupyter-nbextension disable nb_conda --py --sys-prefix \
 && jupyter-serverextension disable nb_conda --py --sys-prefix \
 && jupyter-nbextension disable nb_anacondacloud --py --sys-prefix \
 && jupyter-serverextension disable nb_anacondacloud --py --sys-prefix \
 && jupyter-nbextension disable nbpresent --py --sys-prefix \
 && jupyter-serverextension disable nbpresent --py --sys-prefix \
 # remove packages and clean up 
 && apk del temp-pkgs \
 && rm -rf /tmp/* /var/cache/apk/* /opt/conda/pkgs/* ~/.wget-hsts ~/.[acpw]* ${WORKDIR}/installer.sh
# Set token as empty string - also disables authenticating token for XSRF protection
RUN jupyter notebook --generate-config \
  && echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8888
VOLUME ${WORKDIR}/notebooks
WORKDIR ${WORKDIR}/notebooks
ENTRYPOINT ["/init"]
CMD ["jupyter", "notebook", "--no-browser", "--port=8888", "--ip=0.0.0.0", \
"--config=${WORKDIR}/jupyter_notebook_config.json"]
