from setuptools import setup, find_packages

setup(
    name="venice-hotswap",
    version="1.0.0",
    description="Venice AI Hotswap Engine - Автоматический обход фильтров LLM",
    author="XuViGaN",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.11",
    install_requires=[
        "mcp>=2.0.0",
        "httpx>=0.27.0",
    ],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
    ],
)
